GOOGLE_PROJECT_ID=cymbal-eats
SERVICE_NAME=picture-upload-service

gcloud run deploy $SERVICE_NAME \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --project=$GOOGLE_PROJECT_ID
