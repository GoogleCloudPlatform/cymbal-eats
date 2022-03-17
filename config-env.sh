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

export INVENTORY_SERVICE_NAME=inventory-service
export MENU_SERVICE_NAME=menu-service
export ORDER_SERVICE_NAME=order-service
export PICTURE_UPLOAD_SERVICE_NAME=picture-upload-service

export CUSTOMER_SERVICE_NAME=customer-ui
export EMPLOYEE_SERVICE_NAME=employee-ui

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export PROJECT_NAME=$(gcloud projects describe $PROJECT_ID --format='value(name)')

export REGION=us-east4

gcloud config set run/region $REGION

gcloud auth configure-docker -q
