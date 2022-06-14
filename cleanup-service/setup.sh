source ../config-env.sh

# build image
docker build . -t gcr.io/$PROJECT_NAME/cleanup-service

#push to registry
docker push gcr.io/$PROJECT_NAME/cleanup-service

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
	--image=gcr.io/$PROJECT_NAME/cleanup-service \
	--set-env-vars MENU_SERVICE_URL=$MENU_SERVICE_URL \
	--set-env-vars DURATION=60 \
    --region europe-west9

# schedule Cloud Run job to start once a day at 12:00AM
gcloud scheduler jobs create http cleanup-schedule \
    --location $REGION \
    --schedule="0 0 * * *" \
    --uri="https://$REGION-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/$PROJECT_ID/jobs/cleanup-service:run" \
    --http-method POST \
    --oauth-service-account-email $PROJECT_NUMBER-compute@developer.gserviceaccount.com


