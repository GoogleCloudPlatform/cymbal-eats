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

REGION=us-east1

CUSTOMER_SERVICE_URL=$(gcloud run services describe customer-ui-service \
  --region=$REGION \
  --format=json | jq \
  --raw-output ".status.url")

echo "Customer Portal - ${CUSTOMER_SERVICE_URL}"

EXTERNAL_IP=$(gcloud compute addresses list --filter employee-ui-iap-ip --format='value(ADDRESS)')

echo "Employee Portal - https://${EXTERNAL_IP}.nip.io"
