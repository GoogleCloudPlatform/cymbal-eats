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

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash

export NVM_DIR="/usr/local/nvm"
source $NVM_DIR/nvm.sh;

nvm install 16.4.0
npm install
npm install -g @quasar/cli
npm install -g envsub

if [[ -z "${ORDER_SERVICE_URL}" ]]; then
  ORDER_SERVICE_URL=$(gcloud run services describe $ORDER_SERVICE_NAME \
    --region=$REGION \
    --format=json | jq \
    --raw-output ".status.url")
  export ORDER_SERVICE_URL
else
  echo "Using pre-defined ORDER_SERVICE_URL=$ORDER_SERVICE_URL"
fi

if [[ -z "${INVENTORY_SERVICE_URL}" ]]; then
  INVENTORY_SERVICE_URL=$(gcloud run services describe $INVENTORY_SERVICE_NAME \
    --region=$REGION \
    --format=json | jq \
    --raw-output ".status.url")
  export INVENTORY_SERVICE_URL
else
  echo "Using pre-defined INVENTORY_SERVICE_URL=$INVENTORY_SERVICE_URL"
fi

if [[ -z "${MENU_SERVICE_URL}" ]]; then
  MENU_SERVICE_URL=$(gcloud run services describe $MENU_SERVICE_NAME \
    --region=$REGION \
    --format=json | jq \
    --raw-output ".status.url")
  export MENU_SERVICE_URL
else
  echo "Using pre-defined MENU_SERVICE_URL=$MENU_SERVICE_URL"
fi

envsub .env.tmpl .env

rm -r cloud-run/public/*

quasar clean
quasar build

mkdir -p cloud-run/public
cp -r dist/spa/* cloud-run/public
cd cloud-run

gcloud storage buckets create $UPLOAD_BUCKET --project $PROJECT_ID --location $REGION

gcloud storage buckets add-iam-policy-binding $UPLOAD_BUCKET --member=allUsers --role=roles/storage.objectViewer

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/storage.objectCreator"

gcloud run deploy $EMPLOYEE_SERVICE_NAME \
  --source . \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --set-env-vars=UPLOAD_BUCKET=$UPLOAD_BUCKET \
  --project=$PROJECT_ID \
  --max-instances=2 \
  --quiet
