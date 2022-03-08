# Inventory System 

## Technology Stack

- [GoLang](https://go.dev/)
- [Google Cloud Run](https://cloud.google.com/run)
- [Google Cloud Spanner (Spanner)](https://cloud.google.com/spanner)

## Overview

A simple Go application that can be deployed to Cloud Run that connects to a backend Cloud SQL Postgres database. 

Application includes:
- Automatic Table Migrations
- Automatic Table Seeding
- HTTP Web Paths:
    * "/": Health Check
    * "/getAvailableInventory": Get's current inventory by item
    * "/updateInventoryItem": Receives post request to update inventory item. JSON example: "[{'itemID': int,'inventoryChange': int}]"


## Files

- [cloudbuild.yaml] (cloudbuild.yaml) Build file that can be used to deploy service
- [go.mod] (go.mod)
- [main.go] (main.go) Main Application file
- [README.md] (README.md) This README file.

## Environment Variables
- SPANNER_CONNECTION_STRING `example: projects/<PROJECT>/instances/<SPANNER INSTANCE>/databases/<database>`
- PORT

## Instructions 

### 1. Create your Cloud Spanner Instance

1. (Create new Cloud Spanner Instance)[https://cloud.google.com/spanner/docs/create-manage-instances]
2. Take note of the name of the instance. It can also be found using: `gcloud spanner instances list`
3. Create your connection string: `projects/<PROJECT>/instances/<Instance_ID>/databases/<database>`
    * <database> is what you want to call the database. The GoLang service will create it if not created.
4. (We should see if we need to check IAM permissions)

### 2. Deploy the application to Cloud Run

* (Prerequisite is to have gcloud SDK Installed)

1. Clone the [Cymbal Eats](https://https://github.com/momander/cymbal-eats) git repository to your local machine
2. Open a command line and change directoy to inventory-system/spanner/
3. Run `gcloud run deploy spanner-service --update-env-vars SPANNER_CONNECTION_STRING=<your_connection_string>`
4. The command will output something like this:
`Service URL: https://spanner-service-bawz2x6bda-wl.a.run.app` Click the URL to confirm the service is running correctly!