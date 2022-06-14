# Cleanup Service

## About
Cloud Scheduler is configured to trigger this Cloud Run Job every day at 12:00 AM. The scripts identifies any **failed** menu items older than 1 hr and deletes them.

## Demo
For demo purposes if you want to run the job immediately, use this command to start the job

```
gcloud beta run jobs execute cleanup-service --region europe-west9
```
