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
    vision.googleapis.com \
    cloudfunctions.googleapis.com \
    pubsub.googleapis.com \
    cloudbuild.googleapis.com \
    logging.googleapis.com \
    eventarc.googleapis.com \
    artifactregistry.googleapis.com \
    run.googleapis.com \
    --quiet

export CF_SERVICE_ACCOUNT=thumbnail-service-sa
gcloud iam service-accounts create ${CF_SERVICE_ACCOUNT}

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member "serviceAccount:${CF_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role "roles/artifactregistry.reader"

GCS_SERVICE_ACCOUNT=$(gcloud storage service-agent --project $PROJECT_NUMBER)

gcloud projects add-iam-policy-binding $PROJECT_NUMBER \
    --member "serviceAccount:$GCS_SERVICE_ACCOUNT" \
    --role "roles/pubsub.publisher"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member "serviceAccount:${CF_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role "roles/storage.objectCreator"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member "serviceAccount:${CF_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role "roles/run.invoker"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member "serviceAccount:${CF_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role "roles/eventarc.eventReceiver"

if [[ -z "${MENU_SERVICE_URL}" ]]; then
  MENU_SERVICE_URL=$(gcloud run services describe $MENU_SERVICE_NAME \
    --region=$REGION \
    --format=json | jq \
    --raw-output ".status.url")
  export MENU_SERVICE_URL
else
  echo "Using pre-defined MENU_SERVICE_URL=$MENU_SERVICE_URL"
fi

gcloud storage buckets create --project $PROJECT_ID --location $REGION $BUCKET_THUMBNAILS
gcloud storage buckets add-iam-policy-binding $BUCKET_THUMBNAILS --member=allUsers --role=roles/storage.objectViewer

gcloud storage buckets create --project $PROJECT_ID --location $REGION $UPLOAD_BUCKET
gcloud storage buckets add-iam-policy-binding $UPLOAD_BUCKET --member=allUsers --role=roles/storage.objectViewer

# This is to allow for Eventarc permissions to propagate
sleep 1m

gcloud beta run deploy process-thumbnails \
      --source=thumbnail \
      --function process-thumbnails \
      --region $REGION \
      --base-image google-22-full/nodejs20 \
      --no-allow-unauthenticated \
      --project=$PROJECT_ID \
      --service-account="${CF_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
      --set-env-vars=BUCKET_THUMBNAILS=$BUCKET_THUMBNAILS,MENU_SERVICE_URL=$MENU_SERVICE_URL \
      --max-instances=1 \
      --quiet


# This is to allow for Eventarc permissions to propagate
sleep 3m

gcloud eventarc triggers create process-thumbnails-trigger \
     --location=$REGION \
     --destination-run-service=process-thumbnails \
     --destination-run-region=$REGION \
     --event-filters="type=google.cloud.storage.object.v1.finalized" \
     --event-filters="bucket=$UPLOAD_BUCKET_NAME" \
     --service-account="${CF_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com"
