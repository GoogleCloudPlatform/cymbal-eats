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
    vision.googleapis.com \
    cloudfunctions.googleapis.com

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

gcloud functions deploy process_thumbnails \
  --region=$REGION \
  --trigger-resource=$UPLOAD_BUCKET \
  --trigger-event=google.storage.object.finalize \
  --runtime=nodejs16 \
  --set-env-vars=BUCKET_THUMBNAILS=$BUCKET_THUMBNAILS,MENU_SERVICE_URL=$MENU_SERVICE_URL \
  --source=thumbnail \
  --project=$PROJECT_ID \
  --quiet

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$PROJECT_ID@appspot.gserviceaccount.com" \
  --role="roles/storage.objectCreator"