# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Read GCP_PROJECT_ID from ENVIRONMENT_CONFIG.json
GCP_PROJECT_ID=$(jq -r '.GCP_PROJECT_ID' ${SCRIPT_DIR}/../ENVIRONMENT_CONFIG.json)
GCP_REGION=$(jq -r '.GCP_REGION' ${SCRIPT_DIR}/../ENVIRONMENT_CONFIG.json)

# Create Google Cloud Storage Bucket that will be used for storage of Terraform state
gcloud storage buckets create gs://${GCP_PROJECT_ID}-data --location=${GCP_REGION}

# Create input folder
echo "" | gsutil cp - gs://${GCP_PROJECT_ID}-data/input/.placeholder
