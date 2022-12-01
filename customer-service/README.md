# Deploying customer-service 

## Enable required APIs

```
gcloud services enable \
alloydb.googleapis.com \
compute.googleapis.com \
servicenetworking.googleapis.com \
cloudresourcemanager.googleapis.com \
vpcaccess.googleapis.com \
containerregistry.googleapis.com \
run.googleapis.com
```

## Deploy AlloyDB Cluster

Assign roles to access alloy db.

```
gcloud projects add-iam-policy-binding $PROJECT_NAME \
--member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
--role="roles/alloydb.admin"

gcloud projects add-iam-policy-binding $PROJECT_NAME \
--member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
--role="roles/owner”

gcloud projects add-iam-policy-binding $PROJECT_NAME \
--member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
--role="roles/editor”
```

Create default network

```
gcloud compute networks create default --subnet-mode=auto
```

Create a private connection to Google so that the VM instances in the “default” VPC network can use private services access to reach Google services that support it

```
gcloud compute addresses create google-managed-services-default --global --purpose=VPC_PEERING --prefix-length=16 --description="peering range for Google" --network=default
```

Set up Peering to the default network

```
gcloud services vpc-peerings connect --service=servicenetworking.googleapis.com --ranges=google-managed-services-default --network=default
```

Create an Alloy DB cluster

```
DB_PASSWORD=[password]

gcloud beta alloydb clusters create customer-cluster \
 --password=$DB_PASSWORD \
 --network=default \
 --region=$REGION \
 --project=$PROJECT_NAME
```

Note the OperationID from the output of the previous step and set this variable

```
OPERATION_ID=[OPERATION ID OUTPUT FROM CLUSTER CREATION]
```

Check the status of the cluster

```
gcloud beta alloydb operations describe $OPERATION_ID \
 --region=$REGION \
 --project=$PROJECT_NAME
```

## Create an instance 

```
INSTANCE_ID=customer-instance

gcloud beta alloydb instances create $INSTANCE_ID \
--instance-type=PRIMARY \
--cpu-count=2 \
--region=$REGION \
--cluster=customer-cluster \
--project=$PROJECT_NAME
```

Note the instance IP address. 

## Create a database

To add a database, we need PSQL client. We will create a VM instance to use as a PSQL client

### Stand up a PSQL client

The VM needs external IP so you may have to change the org policy `constraints/compute.vmExternalIpAccess` before running the below command.

```
ZONE=us-central1-a

gcloud compute instances create psql-client --project=$PROJECT_ID --zone=$ZONE --machine-type=e2-medium --network-interface=subnet=default,no-address --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$PROJECT_NUMBER-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/cloud-platform --create-disk=auto-delete=yes,boot=yes,device-name=psql-client,image=projects/debian-cloud/global/images/debian-11-bullseye-v20220719,mode=rw,size=10,type=projects/$PROJECT_ID/zones/us-central1-a/diskTypes/pd-balanced --shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
```

SSH into the VM

```
gcloud compute ssh --project=$PROJECT_NAME --zone=$ZONE psql-client
```

Once you ssh into the box, install postgresql client by running

```
sudo apt-get update 
sudo apt-get install postgresql-client
```

### Connect to the instance and add database

Connect to the database with the instance ip address

```
DB_INSTANCE_IP=[ALLOY INSTANCE IP ADDRESS]
createdb -h $DB_INSTANCE_IP -U postgres customer_db
```

Enter the password to sign into the instance.


## Setup Serverless VPC Connector

Create a serverless VPC Connector as explained [here](https://cloud.google.com/vpc/docs/configure-serverless-vpc-access#create-connector)

Note the name of the serverless VPC connector

```
SERVERLESS_VPC_CONNECTOR=cymbalconnector
```

## Deploy Customer Service on Cloud Run

Clone this repository and change to `customer-service` directory

```
cd customer-service
```

### To build JVM based image
* Compile the application using maven
```
./mvnw package -DskipTests
```
* Build container image
```
docker build -f src/main/docker/Dockerfile.jvm --tag gcr.io/$PROJECT_NAME/customer-service .
```

* Check the container image created
```
$ docker images
REPOSITORY                                                        TAG             IMAGE ID       CREATED              SIZE
gcr.io/PROJECT_NAME/customer-service                                   latest          b6f5cdd4caf1   About a minute ago   162MB
```

Push the image to the remote registry
```
docker push gcr.io/$PROJECT_NAME/customer-service
```

Enable Run APIs

```
gcloud services enable run.googleapis.com
```

Build and deploy Cloud Run service

```
DB_HOST=[ALLOY INSTANCE IP ADDRESS]
DB_USER=postgres
DB_PASSWORD=[password]
DB_DATABASE=customer_db

gcloud run deploy customer-service \
--image=gcr.io/$PROJECT_NAME/customer-service:latest \
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

You'll need a tool like httpie.

### Test GET
```
http GET $URL/customer
```

### Test GET by Id

```
http GET $URL/customer/id1
```

### Test GET by email

[TBD]


### Test POST

```
http POST $URL/customer id='id2' email='eater@foodlover.com' name='Foodie Rich' address='1st Street' city='Manhattan' state='NY' zip='11111' rewardPoints=50
```

Output as below.

```
HTTP/1.1 200 OK
Alt-Svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000,h3-Q050=":443"; ma=2592000,h3-Q046=":443"; ma=2592000,h3-Q043=":443"; ma=2592000,quic=":443"; ma=2592000; v="46,43"
Content-Length: 262
Date: Thu, 28 Jul 2022 16:32:30 GMT
Server: Google Frontend
X-Cloud-Trace-Context: 2f4b15dc67340ca935a08f85c4cd1a88;o=1
content-type: application/json

{
    "createDateTime": "2022-07-28T16:32:30.050761",
    "customerCity": "Manhattan",
    "customerEmail": "eater@foodlover.com",
    "customerName": "Foodie Rich",
    "customerRewardPoints": 0,
    "customerState": "NY",
    "customerZIP": "11111",
    "id": 3,
    "updateDateTime": "2022-07-28T16:32:30.050852"
}

```

### Test PUT

```

ID=[REPLACEME]

http PUT $URL/customer/${ID} email='eater@foodlover.com' name='Foodie Rich' address='1st Street' city='Manhattan' state='NY' zip='11111' rewardPoints=100

```
Output

```
HTTP/1.1 200 OK
Alt-Svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000,h3-Q050=":443"; ma=2592000,h3-Q046=":443"; ma=2592000,h3-Q043=":443"; ma=2592000,quic=":443"; ma=2592000; v="46,43"
Content-Length: 264
Date: Thu, 28 Jul 2022 16:36:49 GMT
Server: Google Frontend
X-Cloud-Trace-Context: e291c0ce55175db66da3e0b55fd1ca35;o=1
content-type: application/json

{
    "createDateTime": "2022-07-28T16:32:30.050761",
    "customerCity": "Manhattan",
    "customerEmail": "eater@foodlover.com",
    "customerName": "Foodie Rich",
    "customerRewardPoints": 100,
    "customerState": "NY",
    "customerZIP": "11111",
    "id": 3,
    "updateDateTime": "2022-07-28T16:36:49.079386"
}
```



### Test DELETE

```

ID=[REPLACEME]

http DELETE $URL/customer/$ID
```

Output
```
HTTP/1.1 204 No Content
Alt-Svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000,h3-Q050=":443"; ma=2592000,h3-Q046=":443"; ma=2592000,h3-Q043=":443"; ma=2592000,quic=":443"; ma=2592000; v="46,43"
Content-Length: 0
Content-Type: text/html
Date: Thu, 28 Jul 2022 16:39:37 GMT
Server: Google Frontend
X-Cloud-Trace-Context: bfebe1d7594bfac1641a19c226b3406d;o=1
```




















