# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Read GCP_PROJECT_ID from ENVIRONMENT_CONFIG.json
GCP_PROJECT_ID=$(jq -r '.GCP_PROJECT_ID' ${SCRIPT_DIR}/../ENVIRONMENT_CONFIG.json)
GCP_REGION=$(jq -r '.GCP_REGION' ${SCRIPT_DIR}/../ENVIRONMENT_CONFIG.json)

gcloud services enable firestore.googleapis.com
gcloud services enable storage.googleapis.com
# Need it for DataLake external tables in BQ
gcloud services enable bigqueryconnection.googleapis.com
# Data Transfer Service is used to refresh materialized views with scheduled query
gcloud services enable bigquerydatatransfer.googleapis.com

# Create Google Cloud Storage Bucket that will be used for storage of Terraform state
gcloud storage buckets create gs://${GCP_PROJECT_ID}-data --location=${GCP_REGION}

# Create input folder
echo "" | gsutil cp - gs://${GCP_PROJECT_ID}-data/input/.placeholder

# Create firestore (default) database
gcloud firestore databases create --location=${GCP_REGION} --project=${GCP_PROJECT_ID}

# Create BQ connection for DataLake
bq mk --connection --location=${GCP_REGION} --project_id=${GCP_PROJECT_ID} \
    --connection_type=CLOUD_RESOURCE data_lake_connection

# Grant access to BQ connection to the service account
# gcloud storage buckets add-iam-policy-binding gs://db-jetblue-assesment-data \
# --member=serviceAccount:bqcx-6579967853-m6v6@gcp-sa-bigquery-condel.iam.gserviceaccount.com \
# --role=roles/storage.objectViewer