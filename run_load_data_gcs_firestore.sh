#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -e|--environment_name)
            ENV_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

if [ -z "$ENV_NAME" ]; then
    echo "Usage: $0 -e <environment_name>"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GCP_PROJECT_ID=$(jq -r --arg env "$ENV_NAME" '.[$env].GCP_PROJECT_ID' ${SCRIPT_DIR}/ENVIRONMENT_CONFIG.json)
TARGET_FIRESTORE_DATABASE_NAME=$(jq -r --arg env "$ENV_NAME" '.[$env].TARGET_FIRESTORE_DATABASE_NAME' ${SCRIPT_DIR}/ENVIRONMENT_CONFIG.json)
FAILED_ROWS_FIRESTORE_DATABASE_NAME=$(jq -r --arg env "$ENV_NAME" '.[$env].FAILED_ROWS_FIRESTORE_DATABASE_NAME' ${SCRIPT_DIR}/ENVIRONMENT_CONFIG.json)

echo "Using GCP Project ID: $GCP_PROJECT_ID"
echo "Using Target Firestore Database Name: $TARGET_FIRESTORE_DATABASE_NAME"
echo "Using Failed Rows Firestore Database Name: $FAILED_ROWS_FIRESTORE_DATABASE_NAME"

# Create output directory if it doesn't exist
mkdir -p "${SCRIPT_DIR}/.output"

python3 ${SCRIPT_DIR}/load_data_gcs_firestore.py \
    --project "$GCP_PROJECT_ID" \
    --database "$TARGET_FIRESTORE_DATABASE_NAME" \
    --failed-rows-database "$FAILED_ROWS_FIRESTORE_DATABASE_NAME" > ${SCRIPT_DIR}/.output/output.txt 2> ${SCRIPT_DIR}/.output/error.txt
