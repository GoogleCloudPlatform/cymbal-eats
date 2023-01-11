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

curl -sL https://firebase.tools | upgrade=true bash

firebase login --no-localhost

firebase --non-interactive projects:addfirebase $PROJECT_ID

export APP_EXISTS=$(curl -H "Authorization: Bearer $(gcloud auth print-access-token)" https://firebase.googleapis.com/v1beta1/projects/$PROJECT_ID/webApps | grep -o -w $CUSTOMER_SERVICE_NAME | wc -w)

if [ "$APP_EXISTS" -eq "0" ]; then
  firebase --non-interactive apps:create -P $PROJECT_ID WEB $CUSTOMER_SERVICE_NAME
fi

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

export API_KEY=$(firebase --non-interactive apps:sdkconfig -P $PROJECT_ID --json | jq --raw-output ".result.sdkConfig.apiKey")
export AUTH_DOMAIN=$(firebase --non-interactive apps:sdkconfig -P $PROJECT_ID --json | jq --raw-output ".result.sdkConfig.authDomain")

envsub .env.tmpl .env

rm -rf cloud-run/public

quasar clean
quasar build

mkdir -p cloud-run/public
cp -r dist/spa/* cloud-run/public
cd cloud-run

gcloud run deploy $CUSTOMER_SERVICE_NAME \
  --source . \
  --platform managed \
  --region $REGION \
  --project=$PROJECT_ID \
  --allow-unauthenticated \
  --max-instances=2 \
  --set-env-vars=VUE_APP_PROJECT_ID=$PROJECT_ID,VUE_APP_API_KEY=$API_KEY,VUE_APP_AUTH_DOMAIN=$AUTH_DOMAIN,VUE_APP_MENU_SERVICE_URL=$MENU_SERVICE_URL,VUE_APP_INVENTORY_SERVICE_URL=$INVENTORY_SERVICE_URL,VUE_APP_ORDER_SERVICE_URL=$ORDER_SERVICE_URL \
  --quiet

printf "\nManual steps\n"

echo "Enable Google sign-in in the Firebase console:"
printf "https://console.firebase.google.com/u/0/project/$PROJECT_ID/authentication/providers"

printf "\n\nAdd Customer UI service domain to Authorized domains under Authentication/Settings:"
printf "\nhttps://console.firebase.google.com/u/0/project/$PROJECT_ID/authentication/settings\n"
