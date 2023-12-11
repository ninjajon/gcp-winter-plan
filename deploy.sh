GOOGLE_CLOUD_PROJECT="jo-winter-plan-igsk"
frontend_version=1.0.0
gcloud config set project ${GOOGLE_CLOUD_PROJECT}

cd frontend
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/run:${frontend_version} .
gcloud beta services identity create --service=iap.googleapis.com --project=${GOOGLE_CLOUD_PROJECT}
terraform init -reconfigure
terraform apply -var="image_version=${frontend_version}" -auto-approve