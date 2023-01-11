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

GCS_SERVICE_ACCOUNT=$(gsutil kms serviceaccount -p $PROJECT_NUMBER)

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

gsutil mb -p $PROJECT_ID -l $REGION $BUCKET_THUMBNAILS
gsutil iam ch allUsers:objectViewer $BUCKET_THUMBNAILS

gsutil mb -p $PROJECT_ID -l $REGION $UPLOAD_BUCKET
gsutil iam ch allUsers:objectViewer $UPLOAD_BUCKET

# This is to allow for Eventarc permissions to propagate
sleep 1m

gcloud functions deploy process-thumbnails \
  --gen2 \
  --runtime=nodejs16 \
  --source=thumbnail \
  --region=$REGION \
  --project=$PROJECT_ID \
  --entry-point=process-thumbnails \
  --trigger-bucket=$UPLOAD_BUCKET \
  --service-account="${CF_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --set-env-vars=BUCKET_THUMBNAILS=$BUCKET_THUMBNAILS,MENU_SERVICE_URL=$MENU_SERVICE_URL \
  --max-instances=1 \
  --quiet

# This is to allow for Eventarc permissions to propagate
sleep 3m

gcloud functions deploy process-thumbnails \
  --gen2 \
  --runtime=nodejs16 \
  --source=thumbnail \
  --region=$REGION \
  --project=$PROJECT_ID \
  --entry-point=process-thumbnails \
  --trigger-bucket=$UPLOAD_BUCKET \
  --service-account="${CF_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --set-env-vars=BUCKET_THUMBNAILS=$BUCKET_THUMBNAILS,MENU_SERVICE_URL=$MENU_SERVICE_URL \
  --max-instances=1 \
  --quiet
