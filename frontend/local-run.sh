python3 -m venv app-streamlit
source app-streamlit/bin/activate

export GCP_PROJECT="jo-winter-plan-igsk"
export GCP_REGION="us-central1"

#gcloud auth application-default login
gcloud config set project $GCP_PROJECT
gcloud config set compute/region $GCP_REGION

python main.py