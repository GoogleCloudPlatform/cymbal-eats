GOOGLE_PROJECT_ID=cymbal-eats
SERVICE_NAME=employee-ui-service

rm -r public/*
cd ..
quasar build
cp -r dist/spa/* cloud-run/public
cd cloud-run

gcloud run deploy $SERVICE_NAME \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --project=$GOOGLE_PROJECT_ID