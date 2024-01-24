
# ```GSP773 Eventarc for Cloud Run```


```
export REGION=
```

```
gcloud config set project $DEVSHELL_PROJECT_ID
gcloud config set run/region $REGION
gcloud config set run/platform managed
gcloud config set eventarc/location $REGION

export PROJECT_NUMBER="$(gcloud projects list --filter=$(gcloud config get-value project) --format='value(PROJECT_NUMBER)')"

gcloud projects add-iam-policy-binding $(gcloud config get-value project) --member=serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com --role='roles/eventarc.admin'

gcloud beta eventarc attributes types list

gcloud beta eventarc attributes types describe \
  google.cloud.pubsub.topic.v1.messagePublished

export SERVICE_NAME=event-display
export IMAGE_NAME="gcr.io/cloudrun/hello"

gcloud run deploy ${SERVICE_NAME} --image ${IMAGE_NAME} --allow-unauthenticated --max-instances=3

gcloud beta eventarc attributes types describe \
  google.cloud.pubsub.topic.v1.messagePublished

gcloud beta eventarc triggers create trigger-pubsub --destination-run-service=${SERVICE_NAME} --matching-criteria="type=google.cloud.pubsub.topic.v1.messagePublished"

export TOPIC_ID=$(gcloud eventarc triggers describe trigger-pubsub --format='value(transport.pubsub.topic)')

gcloud eventarc triggers list

gcloud pubsub topics publish ${TOPIC_ID} --message="Hello there"
```
## ```Task 5: Check the Progress```

```
gcloud eventarc triggers delete trigger-pubsub

export BUCKET_NAME=$(gcloud config get-value project)-cr-bucket

gsutil mb -p $(gcloud config get-value project) \
  -l $(gcloud config get-value run/region) \
  gs://${BUCKET_NAME}/

```

## ```NOTE: Go to IAM & Admin > Audit Logs```

* In the list of services, check the box for Google Cloud Storage.

* On the right hand side, click the LOG TYPE tab. Admin Write is selected by default,
* Make sure you selected All:
> Admin Read

> Data Read

> Data Write

### ```Click on Save:```

```
echo "Hello World" > random.txt

gsutil cp random.txt gs://${BUCKET_NAME}/random.txt

gcloud beta eventarc attributes types describe google.cloud.audit.log.v1.written

gcloud beta eventarc triggers create trigger-auditlog --destination-run-service=${SERVICE_NAME} --matching-criteria="type=google.cloud.audit.log.v1.written" --matching-criteria="serviceName=storage.googleapis.com" --matching-criteria="methodName=storage.objects.create" --service-account=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com

gcloud eventarc triggers list

gsutil cp random.txt gs://${BUCKET_NAME}/random.txt
```

# ```Thanks for Watching :)```
# ```Share, Support, Subscribe!!!```
