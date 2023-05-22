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
    run.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    firestore.googleapis.com \
    pubsub.googleapis.com \
    --quiet

gcloud firestore databases create --location=$FIRESTORE_LOCATION

sed "s/PROJECT_ID/$PROJECT_ID/g" firebaserc.tmpl > .firebaserc

curl -sL https://firebase.tools | upgrade=true bash

sleep 2m

firebase deploy

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

gcloud pubsub topics create $TOPIC_ID --project=$PROJECT_ID
gcloud pubsub topics create $ORDER_POINTS_TOPIC_ID --project=$PROJECT_ID
gcloud pubsub topics create order-points-dead-letter-topic --project=$PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID  \
  --member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/pubsub.publisher"

gcloud run deploy $ORDER_SERVICE_NAME \
  --source . \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --project=$PROJECT_ID \
  --max-instances=3 \
  --set-env-vars=INVENTORY_SERVICE_URL=$INVENTORY_SERVICE_URL \
  --quiet

export ORDER_SERVICE_URL=$(gcloud run services describe $ORDER_SERVICE_NAME \
    --region=$REGION \
    --format=json | jq \
    --raw-output ".status.url")

gcloud pubsub subscriptions create order-points-push-sub \
    --topic=$ORDER_POINTS_TOPIC_ID \
    --push-endpoint=$ORDER_SERVICE_URL/order/points \
    --message-retention-duration=1d \
    --enable-message-ordering \
    --max-delivery-attempts=5 \
    --min-retry-delay=5m \
    --max-retry-delay=10m \
    --dead-letter-topic=order-points-dead-letter-topic \
    --quiet

firebase deploy
