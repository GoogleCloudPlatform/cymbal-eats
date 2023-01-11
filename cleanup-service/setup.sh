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

# build image and push to Artifact Registry
gcloud artifacts repositories create cymbal-eats --repository-format=docker --location=$REGION

gcloud builds submit -t $REGION-docker.pkg.dev/$PROJECT_NAME/cymbal-eats/cleanup-service:latest


#get URL for the Menu Service
if [[ -z "${MENU_SERVICE_URL}" ]]; then
  MENU_SERVICE_URL=$(gcloud run services describe $MENU_SERVICE_NAME \
    --region=$REGION \
    --format=json | jq \
    --raw-output ".status.url")
  export MENU_SERVICE_URL
else
  echo "Using pre-defined MENU_SERVICE_URL=$MENU_SERVICE_URL"
fi


# create a Cloud Run job to clean up failed menu items older than 60 mins
gcloud beta run jobs create cleanup-service \
	--image=$REGION-docker.pkg.dev/$PROJECT_NAME/cymbal-eats/cleanup-service:latest \
	--set-env-vars MENU_SERVICE_URL=$MENU_SERVICE_URL \
	--set-env-vars FAILED_ITEM_AGE=60 \
  --region $REGION

gcloud beta run jobs update cleanup-service \
	--image=$REGION-docker.pkg.dev/$PROJECT_NAME/cymbal-eats/cleanup-service:latest \
	--set-env-vars MENU_SERVICE_URL=$MENU_SERVICE_URL \
	--set-env-vars FAILED_ITEM_AGE=60 \
  --region $REGION

export SCHEDULER_SERVICE_ACCOUNT=cleanup-scheduler-job-sa
gcloud iam service-accounts create ${SCHEDULER_SERVICE_ACCOUNT}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SCHEDULER_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/run.invoker"

# schedule Cloud Run job to start once a day at 12:00AM
gcloud scheduler jobs create http cleanup-schedule \
    --location $REGION \
    --schedule="0 0 * * *" \
    --uri="https://$REGION-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/$PROJECT_ID/jobs/cleanup-service:run" \
    --http-method POST \
    --oauth-service-account-email ${SCHEDULER_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com


