# Cymbal-eats



### Setup

Create a new GCP project, review ```config-env.sh``` file and set ```region``` where you want services to be deployed.
By default ```region``` is set to ```us-east4```.

If you want to use existing services,
you can set following environmental variables.

Example:
```
export ORDER_SERVICE_URL=https://order-service-luu7kai33a-uc.a.run.app
export INVENTORY_SERVICE_URL=https://spanner-inventory-service-luu7kai33a-uc.a.run.app
export MENU_SERVICE_URL=https://menu-service-luu7kai33a-uc.a.run.app
export PICTURE_UPLOAD_SERVICE_URL=https://picture-upload-service-luu7kai33a-uc.a.run.app
```
Run ```./setup.sh``` script located in the root of the project to deploy all components or run ```./setup.sh``` located in each service folder to deploy that component only.

