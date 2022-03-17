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

export VPC_CONNECTOR=cymbalconnector

export DB_INSTANCE_NAME=menu-catalog
export DB_INSTANCE_PASSWORD=password123
export DB_DATABASE=menu-db

export DB_USER=menu-user
export DB_PASSWORD=menupassword123

gcloud services enable \
    sqladmin.googleapis.com \
    run.googleapis.com \
    vpcaccess.googleapis.com \
    servicenetworking.googleapis.com

gcloud compute addresses create google-managed-services-default \
    --global \
    --purpose=VPC_PEERING \
    --prefix-length=20 \
    --network=projects/$PROJECT_ID/global/networks/default

gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services-default \
    --network=default \
    --project=$PROJECT_ID

gcloud beta sql instances create $DB_INSTANCE_NAME \
    --project=$PROJECT_ID \
    --network=projects/$PROJECT_ID/global/networks/default \
    --no-assign-ip \
    --database-version=POSTGRES_12 \
    --cpu=2 \
    --memory=4GB \
    --region=$REGION \
    --root-password=${DB_INSTANCE_PASSWORD}

export DB_INSTANCE_IP=$(gcloud sql instances describe $DB_INSTANCE_NAME \
    --format=json | jq \
    --raw-output ".ipAddresses[].ipAddress")

gcloud sql databases create ${DB_DATABASE} --instance=${DB_INSTANCE_NAME}

gcloud sql users create ${DB_USER} \
    --password=$DB_PASSWORD \
    --instance=${DB_INSTANCE_NAME}

gcloud projects add-iam-policy-binding $PROJECT_ID \
--member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
--role="roles/cloudsql.client"

gcloud compute networks vpc-access connectors create ${VPC_CONNECTOR} \
    --region=${REGION} \
    --range=10.8.0.0/28

./mvnw package -DskipTests

docker build -f src/main/docker/Dockerfile.jvm \
    --tag gcr.io/$PROJECT_NAME/menu-service .

docker push gcr.io/$PROJECT_NAME/menu-service

gcloud run deploy $MENU_SERVICE_NAME \
    --image=gcr.io/$PROJECT_NAME/menu-service:latest \
    --region $REGION \
    --allow-unauthenticated \
    --set-env-vars DB_USER=$DB_USER \
    --set-env-vars DB_PASS=$DB_PASSWORD \
    --set-env-vars DB_DATABASE=$DB_DATABASE \
    --set-env-vars DB_HOST=$DB_INSTANCE_IP \
    --vpc-connector $VPC_CONNECTOR \
    --quiet
