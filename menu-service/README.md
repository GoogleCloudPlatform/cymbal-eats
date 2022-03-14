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
DB_INSTANCE_NAME=menu-catalog

gcloud sql databases create $DB_DATABASE --instance=$DB_INSTANCE_NAME
```

Add a database user

```
DB_USER=[CHANGEME]
DB_PASSWORD=[CHANGEME]
gcloud sql users create $DB_USER \
--instance=$DB_INSTANCE_NAME \
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

You'll need a tool like httpie.

### Test GET
```
http GET $URL/menu
```

Result
```
HTTP/1.1 200 OK
Content-Type: application/json
content-length: 1177

[
    {
        "id": 1,
        "itemImageURL": "https://sheikahplate.files.wordpress.com/2018/03/vegetable_curry_header.jpg?w=720",
        "itemName": "Curry Plate",
        "itemPrice": 12.5,
        "itemThumbnailURL": "https://sheikahplate.files.wordpress.com/2018/03/vegetable_curry_header.jpg?w=720",
        "spiceLevel": 3,
        "status": "Ready",
        "tagLine": "Spicy touch for your taste buds!!"
    },
    {
        "id": 3,
        "itemImageURL": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Gulab_jamun_%28Gibraltar%2C_November_2020%29.jpg/1200px-Gulab_jamun_%28Gibraltar%2C_November_2020%29.jpg",
        "itemName": "Gulab Jamoon",
        "itemPrice": 2.4,
        "itemThumbnailURL": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Gulab_jamun_%28Gibraltar%2C_November_2020%29.jpg/1200px-Gulab_jamun_%28Gibraltar%2C_November_2020%29.jpg",
        "spiceLevel": 0,
        "status": "Failed",
        "tagLine": "Sweet cottage cheese dumplings"
    },
    {
        "id": 2,
        "itemImageURL": "http://nie-images.s3.amazonaws.com/gall_content/2020/10/2020_10$largeimg11_Oct_2020_200729347.jpg",
        "itemName": "Idly Plate",
        "itemPrice": 10.25,
        "itemThumbnailURL": "http://nie-images.s3.amazonaws.com/gall_content/2020/10/2020_10$largeimg11_Oct_2020_200729347.jpg",
        "spiceLevel": 2,
        "status": "Ready",
        "tagLine": "South Indian delight!!"
    }
]
```
### Test GET Ready 

```
http GET $URL/menu/ready
```

Outputs only items that are ready
```
HTTP/1.1 200 OK
Content-Type: application/json
content-length: 685

[
    {
        "id": 1,
        "itemImageURL": "https://sheikahplate.files.wordpress.com/2018/03/vegetable_curry_header.jpg?w=720",
        "itemName": "Curry Plate",
        "itemPrice": 12.5,
        "itemThumbnailURL": "https://sheikahplate.files.wordpress.com/2018/03/vegetable_curry_header.jpg?w=720",
        "spiceLevel": 3,
        "status": "Ready",
        "tagLine": "Spicy touch for your taste buds!!"
    },
    {
        "id": 2,
        "itemImageURL": "http://nie-images.s3.amazonaws.com/gall_content/2020/10/2020_10$largeimg11_Oct_2020_200729347.jpg",
        "itemName": "Idly Plate",
        "itemPrice": 10.25,
        "itemThumbnailURL": "http://nie-images.s3.amazonaws.com/gall_content/2020/10/2020_10$largeimg11_Oct_2020_200729347.jpg",
        "spiceLevel": 2,
        "status": "Ready",
        "tagLine": "South Indian delight!!"
    }
]
```

### Test GET Failed

```
http GET $URL/menu/failed
```

Outputs only failed menu items
```
HTTP/1.1 200 OK
Content-Type: application/json
content-length: 493

[
    {
        "id": 3,
        "itemImageURL": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Gulab_jamun_%28Gibraltar%2C_November_2020%29.jpg/1200px-Gulab_jamun_%28Gibraltar%2C_November_2020%29.jpg",
        "itemName": "Gulab Jamoon",
        "itemPrice": 2.4,
        "itemThumbnailURL": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Gulab_jamun_%28Gibraltar%2C_November_2020%29.jpg/1200px-Gulab_jamun_%28Gibraltar%2C_November_2020%29.jpg",
        "spiceLevel": 0,
        "status": "Failed",
        "tagLine": "Sweet cottage cheese dumplings"
    }
]
```

### Test GET by Id

```
http GET $URL/menu/2
```

Output

```
HTTP/1.1 200 OK
Alt-Svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000,h3-Q050=":443"; ma=2592000,h3-Q046=":443"; ma=2592000,h3-Q043=":443"; ma=2592000,quic=":443"; ma=2592000; v="46,43"
Content-Length: 351
Date: Mon, 14 Mar 2022 21:18:04 GMT
Server: Google Frontend
X-Cloud-Trace-Context: 58a648b21ecefc78c5cff41fc8dace65;o=1
content-type: application/json

{
    "id": 2,
    "itemImageURL": "http://nie-images.s3.amazonaws.com/gall_content/2020/10/2020_10$largeimg11_Oct_2020_200729347.jpg",
    "itemName": "Idly Plate",
    "itemPrice": 10.25,
    "itemThumbnailURL": "http://nie-images.s3.amazonaws.com/gall_content/2020/10/2020_10$largeimg11_Oct_2020_200729347.jpg",
    "spiceLevel": 2,
    "status": "Ready",
    "tagLine": "South Indian delight!!"
}

```


### Test POST

Note the POST request doesnt include status field.
```
http POST $URL/menu itemName=Rasgulla itemPrice=3.2 tagLine="East Indian Cottage Cheese dumplings" itemImageURL="https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg" itemThumbnailURL="https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg"
```

Output as below. Note the status is automatically set to `Processing`

```
HTTP/1.1 200 OK
Content-Type: application/json
content-length: 316

{
    "id": 4,
    "itemImageURL": "https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg",
    "itemName": "Rasgulla",
    "itemPrice": 3.2,
    "itemThumbnailURL": "https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg",
    "spiceLevel": 0,
    "status": "Processing",
    "tagLine": "East Indian Cottage Cheese dumplings"
}

```

Check with GET again to see the data

```
HTTP/1.1 200 OK
Content-Type: application/json
content-length: 1495

[
    {
        "id": 1,
        "itemImageURL": "https://sheikahplate.files.wordpress.com/2018/03/vegetable_curry_header.jpg?w=720",
        "itemName": "Curry Plate",
        "itemPrice": 12.5,
        "itemThumbnailURL": "https://sheikahplate.files.wordpress.com/2018/03/vegetable_curry_header.jpg?w=720",
        "spiceLevel": 3,
        "status": "Ready",
        "tagLine": "Spicy touch for your taste buds!!"
    },
    {
        "id": 3,
        "itemImageURL": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Gulab_jamun_%28Gibraltar%2C_November_2020%29.jpg/1200px-Gulab_jamun_%28Gibraltar%2C_November_2020%29.jpg",
        "itemName": "Gulab Jamoon",
        "itemPrice": 2.4,
        "itemThumbnailURL": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Gulab_jamun_%28Gibraltar%2C_November_2020%29.jpg/1200px-Gulab_jamun_%28Gibraltar%2C_November_2020%29.jpg",
        "spiceLevel": 0,
        "status": "Failed",
        "tagLine": "Sweet cottage cheese dumplings"
    },
    {
        "id": 2,
        "itemImageURL": "http://nie-images.s3.amazonaws.com/gall_content/2020/10/2020_10$largeimg11_Oct_2020_200729347.jpg",
        "itemName": "Idly Plate",
        "itemPrice": 10.25,
        "itemThumbnailURL": "http://nie-images.s3.amazonaws.com/gall_content/2020/10/2020_10$largeimg11_Oct_2020_200729347.jpg",
        "spiceLevel": 2,
        "status": "Ready",
        "tagLine": "South Indian delight!!"
    },
    {
        "id": 4,
        "itemImageURL": "https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg",
        "itemName": "Rasgulla",
        "itemPrice": 3.2,
        "itemThumbnailURL": "https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg",
        "spiceLevel": 0,
        "status": "Processing",
        "tagLine": "East Indian Cottage Cheese dumplings"
    }
]

```

Test GET with `processing`

```
http GET $URL/menu/processing
```

Output
```
HTTP/1.1 200 OK
Content-Type: application/json
content-length: 319

[
    {
        "id": 4,
        "itemImageURL": "https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg",
        "itemName": "Rasgulla",
        "itemPrice": 3.2,
        "itemThumbnailURL": "https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg",
        "spiceLevel": 0,
        "status": "Processing",
        "tagLine": "East Indian Cottage Cheese dumplings"
    }
]

```

### Test PUT

```
http PUT $URL/menu/4 itemName=Roshogulla itemPrice=3.2 tagLine="East Indian Cottage Cheese dumplings" itemImageURL="https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg" itemThumbnailURL="https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg" status="Ready"
```
Output

```
HTTP/1.1 200 OK
Content-Type: application/json
content-length: 313

{
    "id": 4,
    "itemImageURL": "https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg",
    "itemName": "Roshogulla",
    "itemPrice": 3.2,
    "itemThumbnailURL": "https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg",
    "spiceLevel": 0,
    "status": "Ready",
    "tagLine": "East Indian Cottage Cheese dumplings"
}
```
Test with GET ready items again

```
HTTP/1.1 200 OK
Content-Type: application/json
content-length: 1000

[
    {
        "id": 1,
        "itemImageURL": "https://sheikahplate.files.wordpress.com/2018/03/vegetable_curry_header.jpg?w=720",
        "itemName": "Curry Plate",
        "itemPrice": 12.5,
        "itemThumbnailURL": "https://sheikahplate.files.wordpress.com/2018/03/vegetable_curry_header.jpg?w=720",
        "spiceLevel": 3,
        "status": "Ready",
        "tagLine": "Spicy touch for your taste buds!!"
    },
    {
        "id": 2,
        "itemImageURL": "http://nie-images.s3.amazonaws.com/gall_content/2020/10/2020_10$largeimg11_Oct_2020_200729347.jpg",
        "itemName": "Idly Plate",
        "itemPrice": 10.25,
        "itemThumbnailURL": "http://nie-images.s3.amazonaws.com/gall_content/2020/10/2020_10$largeimg11_Oct_2020_200729347.jpg",
        "spiceLevel": 2,
        "status": "Ready",
        "tagLine": "South Indian delight!!"
    },
    {
        "id": 4,
        "itemImageURL": "https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg",
        "itemName": "Roshogulla",
        "itemPrice": 3.2,
        "itemThumbnailURL": "https://rakskitchen.net/wp-content/uploads/2010/10/homemade-rasgulla.jpg",
        "spiceLevel": 0,
        "status": "Ready",
        "tagLine": "East Indian Cottage Cheese dumplings"
    }
]

```

### Test DELETE

```
http DELETE $URL/menu/4
```

Output
```
HTTP/1.1 204 No Content
Alt-Svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000,h3-Q050=":443"; ma=2592000,h3-Q046=":443"; ma=2592000,h3-Q043=":443"; ma=2592000,quic=":443"; ma=2592000; v="46,43"
Content-Length: 0
Content-Type: text/html
Date: Tue, 15 Feb 2022 19:07:56 GMT
Server: Google Frontend
X-Cloud-Trace-Context: 4bb1d40d73dbc39464e4f6b8ab32b290;o=1
```




















