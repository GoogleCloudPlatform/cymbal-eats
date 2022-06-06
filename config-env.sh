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

export CUSTOMER_SERVICE_NAME=customer-ui-service
export EMPLOYEE_SERVICE_NAME=employee-ui-service

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export PROJECT_NAME=$(gcloud projects describe $PROJECT_ID --format='value(name)')

export UPLOAD_BUCKET=gs://menu-item-uploads-$PROJECT_ID
export BUCKET_THUMBNAILS=gs://menu-item-thumbnails-$PROJECT_ID

gcloud config set project $PROJECT_ID

gcloud services enable \
    compute.googleapis.com \
    appengine.googleapis.com \
    firestore.googleapis.com \
    sqladmin.googleapis.com \
    vpcaccess.googleapis.com \
    servicenetworking.googleapis.com \
    spanner.googleapis.com \
    run.googleapis.com \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com \
    vpcaccess.googleapis.com \
    vision.googleapis.com \
    cloudfunctions.googleapis.com \
    iap.googleapis.com \
    cloudresourcemanager.googleapis.com \
    pubsub.googleapis.com \
    workflows.googleapis.com \
    workflowexecutions.googleapis.com \
    eventarc.googleapis.com \
    --quiet

export REGION=us-east1
export WORKFLOW_LOCATION=$REGION
export TRIGGER_LOCATION=$REGION

gcloud config set run/region $REGION

gcloud config set compute/region $REGION

gcloud config set workflows/location ${WORKFLOW_LOCATION}

gcloud config set eventarc/location ${TRIGGER_LOCATION}

gcloud auth configure-docker gcr.io -q

