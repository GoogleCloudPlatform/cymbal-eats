# Deploying menu-service 

## Deploy CloudSQL

Enable service APIs

```
gcloud services enable sqladmin.googleapis.com
```

Create a new CloudSQL instance of type Postgres with name `menu-catalog` and a Private IP using the steps explained [here](https://cloud.google.com/sql/docs/postgres/quickstart-private-ip#create-instance). This step will take several minutes.

Copy the Private IP to connect to the database.
```
DB_HOST=[VALUE OF PRIVATEIP]
```

Create a database with name `menu-db` in this `menu-catalog` CloudSQL instance running

```
DB_DATABASE=menu-db
gcloud sql databases create $DB_DATABASE --instance=$DB_HOST
```

Add a database user

```
DB_USER=[CHANGEME]
DB_PASSWORD=[CHANGEME]
gcloud sql users create $DB_USER \
--instance=$DB_HOST \
--password=$DB_PASSWORD
```

## Configure access to CloudSQL

Assign `cloudsql.client` role to the service account that runs Cloud Run

```
PROJECT_NAME=$(gcloud config get-value project)

PROJECT_NUMBER=`eval echo $(gcloud projects describe $PROJECT_NAME | grep projectNumber | awk '{print $2}'  -)`

gcloud projects add-iam-policy-binding $PROJECT_NAME \
--member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
--role="roles/cloudsql.client"
```

## Setup Serverless VPC Connector

Create a serverless VPC Connector as explained [here](https://cloud.google.com/vpc/docs/configure-serverless-vpc-access#create-connector)

Note the name of the serverless VPC connector

```
SERVERLESS_VPC_CONNECTOR=cymbalconnector
```

## Deploy Menu Service on Cloud Run

Clone this repository and change to `menu-service` directory

```
cd menu-service
```

### To build JVM based image
* Compile the application using maven
```
./mvnw package -DskipTests
```
* Build container image
```
docker build -f src/main/docker/Dockerfile.jvm --tag gcr.io/$PROJECT_NAME/menu-service .
```

### To build native image
* Install GraalVM
* Package the application natively
```
./mvnw package -Pnative -DskipTests
```
* Build native container image
```
docker build -f src/main/docker/Dockerfile.native --tag gcr.io/$PROJECT_NAME/menu-service .
```
* The image size should be pretty small
```
$ docker images
REPOSITORY                                                        TAG             IMAGE ID       CREATED              SIZE
gcr.io/PROJECT_NAME/menu-service                                   latest          b6f5cdd4caf1   About a minute ago   162MB
```

Push the image to the remote registry
```
docker push gcr.io/$PROJECT_NAME/menu-service
```

Enable Run APIs

```
gcloud services enable run.googleapis.com
```

Build and deploy Cloud Run service

```
gcloud run deploy menu-service \
--image=gcr.io/$PROJECT_NAME/menu-service:latest \
--set-env-vars DB_USER=$DB_USER \
--set-env-vars DB_PASS=$DB_PASSWORD \
--set-env-vars DB_DATABASE=$DB_DATABASE \
--set-env-vars DB_HOST=$DB_HOST \
--vpc-connector $SERVERLESS_VPC_CONNECTOR
```

Note the URL for the service

```
URL=SERVICE URL
```

## Test the Service















This project uses Quarkus, the Supersonic Subatomic Java Framework.

If you want to learn more about Quarkus, please visit its website: https://quarkus.io/ .

## Running the application in dev mode

You can run your application in dev mode that enables live coding using:
```shell script
./mvnw compile quarkus:dev
```

> **_NOTE:_**  Quarkus now ships with a Dev UI, which is available in dev mode only at http://localhost:8080/q/dev/.

## Packaging and running the application

The application can be packaged using:
```shell script
./mvnw package
```
It produces the `quarkus-run.jar` file in the `target/quarkus-app/` directory.
Be aware that it’s not an _über-jar_ as the dependencies are copied into the `target/quarkus-app/lib/` directory.

The application is now runnable using `java -jar target/quarkus-app/quarkus-run.jar`.

If you want to build an _über-jar_, execute the following command:
```shell script
./mvnw package -Dquarkus.package.type=uber-jar
```

The application, packaged as an _über-jar_, is now runnable using `java -jar target/*-runner.jar`.

## Creating a native executable

You can create a native executable using: 
```shell script
./mvnw package -Pnative
```

Or, if you don't have GraalVM installed, you can run the native executable build in a container using: 
```shell script
./mvnw package -Pnative -Dquarkus.native.container-build=true
```

You can then execute your native executable with: `./target/menu-service-1.0.0-runner`

If you want to learn more about building native executables, please consult https://quarkus.io/guides/maven-tooling.

## Provided Code

### RESTEasy JAX-RS

Easily start your RESTful Web Services

[Related guide section...](https://quarkus.io/guides/getting-started#the-jax-rs-resources)
