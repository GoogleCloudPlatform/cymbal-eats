### How to set up and test this service

1. Create a new GCP project.
1. Enable these APIs in it:
    * Firestore, native mode
    * Cloud Run
    * Cloud Build
1. Run ```npm install```
1. Open ```deploy.sh``` in an editor. Set ```GOOGLE_PROJECT_ID``` to the id
   of the project you created above.
1. Run ```./deploy.sh```.
1. Open ```create-partner.sh``` in an editor. Replace the text
   ```http://localhost:8080``` with the URL to the service you
   deployed in the previous step.
1. Run ```./create-partner.sh```.
1. Open Firestore in the Cloud Console. Verify that an order was added.
1. Open ```get-partners.sh``` in an editor. Replace the text
   ```http://localhost:8080``` with the URL to the service you
   deployed above.
1. Run ```./get-partners.sh```.
1. Verify that you got the JSON for the order you saw previously in Firestore.
1. Congratulations, you are done!
