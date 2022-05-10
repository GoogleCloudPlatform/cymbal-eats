GOOGLE_PROJECT_ID=cymbal-eats
SERVICE_NAME=order-service

gcloud run deploy $SERVICE_NAME \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --project=$GOOGLE_PROJECT_ID \
  --set-env-vars INVENTORY_SERVICE_URL=https://spanner-inventory-service-luu7kai33a-uc.a.run.app/

