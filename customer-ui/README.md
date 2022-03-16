# Cymbal Eats (cymbal-eats)

An app for hungry people

## Install the dependencies
```bash
npm install
```

## Install quasar cli
```bash
npm install -g @quasar/cli
```

### Start the app in development mode (hot-code reloading, error reporting, etc.)
```bash
quasar dev
```

### Build the app for production
```bash
quasar build
```

### Customize the configuration
See [Configuring quasar.conf.js](https://quasar.dev/quasar-cli/quasar-conf-js).

Externalizing env config
```sh
quasar ext add @quasar/dotenv
```

### Build and push Docker image
```bash
quasar build

docker build -f Dockerfile --tag gcr.io/$PROJECT_NAME/cymbal-eats-client dist

docker push gcr.io/$PROJECT_NAME/cymbal-eats-client
```

### Deploy the app

Check/set REGION before deploying the app.

Example: REGION=us-east4
```bash
gcloud run deploy cymbal-eats-client \
--image=gcr.io/$PROJECT_NAME/cymbal-eats-client:latest \
--port=80 --region=$REGION \
--allow-unauthenticated \
-q
```
