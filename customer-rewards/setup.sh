#!/usr/bin/env bash

# Copyright 2022 Google LLC
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
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    pubsub.googleapis.com \
    workflows.googleapis.com \
    eventarc.googleapis.com \
    workflowexecutions.googleapis.com \
    --quiet

gcloud run deploy customer-rewards \
  --source . \
  --platform managed \
  --no-allow-unauthenticated \
  --ingress=internal \
  --region $REGION \
  --project=$PROJECT_ID \
  --quiet

CUSTOMER_REWARDS_SERVICE_URL=$(gcloud run services describe customer-rewards \
  --platform managed \
  --region $REGION \
  --format=json | jq \
  --raw-output ".status.url")

sed "s@CUSTOMER_REWARDS_SERVICE_URL@$CUSTOMER_REWARDS_SERVICE_URL@g" rewardsWorkflow.yaml.tmpl > rewardsWorkflow.yaml

gcloud config set workflows/location ${REGION}

export WORKFLOW_SERVICE_ACCOUNT=workflows-cloudrun-sa

gcloud iam service-accounts create ${WORKFLOW_SERVICE_ACCOUNT}
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member "serviceAccount:${WORKFLOW_SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com" \
  --role "roles/run.invoker"

export WORKFLOW_NAME=rewardsWorkflow

gcloud workflows deploy ${WORKFLOW_NAME} \
  --source=rewardsWorkflow.yaml \
  --service-account=${WORKFLOW_SERVICE_ACCOUNT}@$PROJECT_ID.iam.gserviceaccount.com

gcloud pubsub topics create $TOPIC_ID --project=$PROJECT_ID

gcloud config set eventarc/location ${REGION}

export TRIGGER_SERVICE_ACCOUNT=eventarc-workflow-sa

gcloud iam service-accounts create ${TRIGGER_SERVICE_ACCOUNT}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${TRIGGER_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/workflows.invoker"

gcloud eventarc triggers create new-orders-trigger \
  --destination-workflow=${WORKFLOW_NAME} \
  --destination-workflow-location=${REGION} \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" \
  --service-account="${TRIGGER_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --transport-topic=$TOPIC_ID

