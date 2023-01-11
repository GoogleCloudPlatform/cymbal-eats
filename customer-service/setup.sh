#!/usr/bin/env bash

# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source ../config-env.sh

export BASE_DIR=$PWD

gcloud services enable \
    alloydb.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    pubsub.googleapis.com \
    workflows.googleapis.com \
    eventarc.googleapis.com \
    workflowexecutions.googleapis.com \
    servicenetworking.googleapis.com \
    cloudresourcemanager.googleapis.com \
    vpcaccess.googleapis.com \
    compute.googleapis.com \
    --quiet

gcloud projects add-iam-policy-binding $PROJECT_NAME \
  --member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/alloydb.client"

gcloud compute addresses create google-managed-services-default \
    --global \
    --purpose=VPC_PEERING \
    --prefix-length=20 \
    --network=projects/$PROJECT_ID/global/networks/default

gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services-default \
    --network=default \
    --project=$PROJECT_ID

DB_DATABASE=customers
DB_USER=postgres
DB_PASSWORD=password123
CLUSTER=customer-cluster
INSTANCE=customer-instance

ALLOYDB_REGION=us-central1
gcloud beta alloydb clusters create $CLUSTER \
    --password=$DB_PASSWORD \
    --network=default \
    --region=$ALLOYDB_REGION \
    --project=$PROJECT_NAME

gcloud beta alloydb clusters describe $CLUSTER --region=$ALLOYDB_REGION

gcloud beta alloydb instances create $INSTANCE \
    --cluster=$CLUSTER \
    --region=$ALLOYDB_REGION \
    --instance-type=PRIMARY \
    --cpu-count=2 \
    --project=$PROJECT_NAME

gcloud beta alloydb instances describe $INSTANCE --cluster=$CLUSTER --region $ALLOYDB_REGION

export DB_HOST=$(gcloud beta alloydb instances describe $INSTANCE \
    --cluster=$CLUSTER \
    --region=$ALLOYDB_REGION \
    --format=json | jq \
    --raw-output ".ipAddress")

export VPC_CONNECTOR=cymbalconnector

gcloud compute networks vpc-access connectors create ${VPC_CONNECTOR} \
    --region=${REGION} \
    --range=10.8.0.0/28

gcloud artifacts repositories create cymbal-eats \
  --repository-format=docker \
  --location=$REGION

cd ./db

gcloud builds submit -t $REGION-docker.pkg.dev/$PROJECT_NAME/cymbal-eats/db-job:latest

gcloud beta run jobs create db-job \
    --image=$REGION-docker.pkg.dev/$PROJECT_NAME/cymbal-eats/db-job:latest \
    --set-env-vars DB_HOST=$DB_HOST \
    --set-env-vars PGUSER=$DB_USER \
    --set-env-vars PGPASSWORD=$DB_PASSWORD \
    --set-env-vars PGDB=$DB_DATABASE \
    --vpc-connector $VPC_CONNECTOR \
    --region $REGION

gcloud beta run jobs execute db-job --region $REGION

cd ..

./mvnw clean package -DskipTests

gcloud auth configure-docker $REGION-docker.pkg.dev --quiet

docker build -f src/main/docker/Dockerfile.jvm --tag customer-service .

docker tag customer-service $REGION-docker.pkg.dev/$PROJECT_NAME/cymbal-eats/customer-service:latest

docker push $REGION-docker.pkg.dev/$PROJECT_NAME/cymbal-eats/customer-service:latest

gcloud run deploy customer-service \
  --image=$REGION-docker.pkg.dev/$PROJECT_NAME/cymbal-eats/customer-service:latest \
  --set-env-vars DB_USER=$DB_USER \
  --set-env-vars DB_PASS=$DB_PASSWORD \
  --set-env-vars DB_DATABASE=$DB_DATABASE \
  --set-env-vars DB_HOST=$DB_HOST \
  --vpc-connector $VPC_CONNECTOR \
  --region $REGION \
  --platform managed \
  --no-allow-unauthenticated \
  --ingress=internal \
  --min-instances=1 \
  --max-instances=3 \
  --quiet

export CUSTOMER_SERVICE_URL=$(gcloud run services describe customer-service \
  --platform managed \
  --region $REGION \
  --format=json | jq \
  --raw-output ".status.url")

sed "s@CUSTOMER_SERVICE_URL@$CUSTOMER_SERVICE_URL@g" rewardsWorkflow.yaml.tmpl > rewardsWorkflow.yaml

gcloud config set workflows/location ${REGION}

export WORKFLOW_SERVICE_ACCOUNT=workflows-cloudrun-sa

gcloud iam service-accounts create ${WORKFLOW_SERVICE_ACCOUNT}
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member "serviceAccount:${WORKFLOW_SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com" \
  --role "roles/run.invoker"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member "serviceAccount:${WORKFLOW_SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com" \
  --role "roles/logging.logWriter"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member "serviceAccount:${WORKFLOW_SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com" \
  --role "roles/pubsub.publisher"

export WORKFLOW_NAME=rewardsWorkflow

gcloud workflows deploy ${WORKFLOW_NAME} \
  --source=rewardsWorkflow.yaml \
  --service-account=${WORKFLOW_SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com

export TOPIC_ID=order-topic
export ORDER_POINTS_TOPIC_ID=order-points-topic

gcloud pubsub topics create $TOPIC_ID --project=$PROJECT_ID
gcloud pubsub topics create $ORDER_POINTS_TOPIC_ID --project=$PROJECT_ID

gcloud config set eventarc/location ${REGION}

export TRIGGER_SERVICE_ACCOUNT=eventarc-workflow-sa

gcloud iam service-accounts create ${TRIGGER_SERVICE_ACCOUNT}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${TRIGGER_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/workflows.invoker"

sleep 2m

gcloud eventarc triggers create new-orders-trigger \
  --destination-workflow=${WORKFLOW_NAME} \
  --destination-workflow-location=${REGION} \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" \
  --service-account="${TRIGGER_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --transport-topic=$TOPIC_ID

