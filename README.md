## Deployment

0- Enable the following APIs
```
    "cloudbuild.googleapis.com",           //Cloud Build API
    "aiplatform.googleapis.com",           //Vertex AI API
    "artifactregistry.googleapis.com",     //Artifact Registry API
    "bigquery.googleapis.com",             //BigQuery API
    "bigquerymigration.googleapis.com",    //BigQuery Migration API
    "bigquerystorage.googleapis.com",      //BigQuery Storage API
    "cloudresourcemanager.googleapis.com", //Cloud Resource Manager API
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",                  //Cloud Run API
    "cloudsearch.googleapis.com",          //Cloud Search API
    "compute.googleapis.com",              //Compute Engine API
    "dataflow.googleapis.com",             //Dataflow API
    "deploymentmanager.googleapis.com",    //Cloud Deployment Manager V2 API
    "dialogflow.googleapis.com",
    "discoveryengine.googleapis.com",      //Discovery Engine API
    "logging.googleapis.com",              //Cloud Logging API
    "ml.googleapis.com",                   //AI Platform Training & Prediction API
    "notebooks.googleapis.com",            //Notebooks API
    "oslogin.googleapis.com",              //Cloud OS Login API
    "serviceusage.googleapis.com",         //Service Usage API
    "storage.googleapis.com",              //Cloud Storage API
    "storage-api.googleapis.com",          //Google Cloud Storage JSON API
    "storage-component.googleapis.com",     //Cloud Storage
    "iap.googleapis.com"
```

1- Change project id in:
```
- deploy.sh
- /frontend/providers.tf
- /frontend/variables.tf
```

2- Set a `dns_name` for the web app app in `frontend/variables.tf`

3- Create a GCS bucket and upload files to be searched on

4- Give the `Storage Object Viewer` role to the discoveryengine default service account. 

``` bash
project_id="jo-winter-plan-igsk"
project_number="484159603515"
gcloud config set project $project_id
gcloud projects add-iam-policy-binding $project_id --member="serviceAccount:service-$project_number@gcp-sa-discoveryengine.iam.gserviceaccount.com" --role="roles/storage.objectViewer"
```

5- Create one Search Gen App Builder app and copy/paste the code into `/frontend/templates/index.html`

- Make sure to enable `Public Access` and add your domain to the allow-list.
- Make sure to set the domain name for the web site in the `/frontend/variables.tf`

6- Create one Chat Gen App Builder app and replace the `project-id` and `agent-id` in the same file with the ones from your new app.

7- Configure and finetune both the Search and Infobot using the GCP console

8- Run `deploy.sh` (you may need to run chmod +x deploy.sh first)

9- Setup the OAuth consent screen for IAP from within the GCP console and grant `IAP Web user` role on the IAP app to the users of your choice

10- Go into the OAuth2 settings of your IAP app and copy paste to the `main.tf` file, in the `iap_config` block, the client id and secret.  Redeploy.