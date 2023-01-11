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

export USER_EMAIL=$(gcloud config list account --format "value(core.account)")

gcloud services enable \
    iap.googleapis.com \
    cloudresourcemanager.googleapis.com

gcloud alpha iap oauth-brands create \
    --application_title="Cymbal Eats" \
    --support_email=$USER_EMAIL

gcloud alpha iap oauth-clients create \
    projects/$PROJECT_ID/brands/$PROJECT_NUMBER \
    --display_name=cymbal-eats-employee-ui

gcloud compute network-endpoint-groups create employee-ui-iap-neg \
    --project $PROJECT_ID \
    --region=$REGION \
    --network-endpoint-type=serverless  \
    --cloud-run-service=employee-ui-service

export CLIENT_NAME=$(gcloud alpha iap oauth-clients list \
    projects/$PROJECT_NUMBER/brands/$PROJECT_NUMBER --format='value(name)' \
    --filter="displayName:cymbal-eats-employee-ui")

export CLIENT_ID=${CLIENT_NAME##*/}

export CLIENT_SECRET=$(gcloud alpha iap oauth-clients describe $CLIENT_NAME --format='value(secret)')

gcloud compute backend-services create employee-ui-iap-backend \
    --load-balancing-scheme=EXTERNAL \
    --global \
    --iap=enabled,oauth2-client-id=$CLIENT_ID,oauth2-client-secret=$CLIENT_SECRET

gcloud compute backend-services add-backend employee-ui-iap-backend \
    --global \
    --network-endpoint-group=employee-ui-iap-neg \
    --network-endpoint-group-region=$REGION

gcloud compute url-maps create employee-ui-iap-url-map \
    --default-service employee-ui-iap-backend

gcloud compute addresses create employee-ui-iap-ip \
    --network-tier=PREMIUM \
    --ip-version=IPV4 \
    --global

export EXTERNAL_IP=$(gcloud compute addresses list --filter employee-ui-iap-ip --format='value(ADDRESS)')

export DOMAIN=${EXTERNAL_IP}.nip.io

gcloud compute ssl-certificates create employee-ui-iap-cert \
    --description=employee-ui-iap-cert \
    --domains=$DOMAIN \
    --global

gcloud compute target-https-proxies create employee-ui-iap-http-proxy \
    --ssl-certificates employee-ui-iap-cert \
    --url-map employee-ui-iap-url-map

gcloud compute forwarding-rules create employee-ui-iap-forwarding-rule \
    --load-balancing-scheme=EXTERNAL \
    --network-tier=PREMIUM \
    --address=employee-ui-iap-ip \
    --global \
    --ports 443 \
    --target-https-proxy employee-ui-iap-http-proxy

export BACKEND_SERVICE=$(gcloud compute backend-services list --filter="name~'employee-ui-iap-backend'" --format="value(name)")

gcloud iap web add-iam-policy-binding \
    --resource-type=backend-services \
    --service $BACKEND_SERVICE \
    --member=user:$USER_EMAIL \
    --role='roles/iap.httpsResourceAccessor'

gcloud run services update $EMPLOYEE_SERVICE_NAME \
    --ingress internal-and-cloud-load-balancing \
    --region $REGION

# Manual Steps
# Go to [OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent?_ga=2.130198351.1761251243.1647864901-1887242533.1645241331) and change User type to External, set Publishing status to Testing.
echo "Go to [OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent?_ga=2.130198351.1761251243.1647864901-1887242533.1645241331) and change User type to External, set Publishing status to Testing."

echo "Cert provisioning might take up to 15 minutes"
echo "Navigate to https://$DOMAIN to access the service"
