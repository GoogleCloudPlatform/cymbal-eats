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
    appengine.googleapis.com \
    run.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    firestore.googleapis.com \
    pubsub.googleapis.com \
    workflows.googleapis.com \
    eventarc.googleapis.com \
    workflowexecutions.googleapis.com

gcloud app create --region=$REGION

gcloud firestore databases create --region=$REGION

sed "s/PROJECT_ID/$PROJECT_ID/g" firebaserc.tmpl > .firebaserc

curl -sL https://firebase.tools | bash
firebase deploy --only firestore:rules

if [[ -z "${INVENTORY_SERVICE_URL}" ]]; then
  INVENTORY_SERVICE_URL=$(gcloud run services describe $INVENTORY_SERVICE_NAME \
    --region=$REGION \
    --format=json | jq \
    --raw-output ".status.url")
  export INVENTORY_SERVICE_URL
else
  echo "Using pre-defined INVENTORY_SERVICE_URL=$INVENTORY_SERVICE_URL"
fi

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/datastore.user"

gcloud run deploy $ORDER_SERVICE_NAME \
  --source . \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --project=$PROJECT_ID \
  --set-env-vars=INVENTORY_SERVICE_URL=$INVENTORY_SERVICE_URL \
  --quiet

export TOPIC_ID=order-topic
gcloud pubsub topics create $TOPIC_ID --project=$PROJECT_ID
gcloud pubsub subscriptions create order-subscription --topic=$TOPIC_ID --topic-project=$PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
--role="roles/pubsub.publisher" 

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
--role="roles/pubsub.subscriber" 

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
--role="roles/workflows.invoker"

export WORKFLOW_SERVICE_ACCOUNT=cymbal-eats-workflow-sa
gcloud iam service-accounts create ${WORKFLOW_SERVICE_ACCOUNT}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${WORKFLOW_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/workflows.invoker"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${WORKFLOW_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role='roles/iam.serviceAccountTokenCreator'

export WORKFLOW_NAME=testWorkflow
gcloud workflows deploy ${WORKFLOW_NAME} --source=testWorkflow.yaml

gcloud eventarc triggers create events-pubsub-trigger \
  --destination-workflow=${WORKFLOW_NAME} \
  --destination-workflow-location=${WORKFLOW_LOCATION} \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" \
  --service-account="${WORKFLOW_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --transport-topic=$TOPIC_ID