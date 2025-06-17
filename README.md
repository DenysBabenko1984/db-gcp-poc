# db-gcp-poc

## Development environment setup

1. Install required components.
    1.1 Install `jq` It will be used for parsing of json config file in bash scripts https://jqlang.org/
    1.2 Install Google Cloud SDK (cli) https://cloud.google.com/sdk/docs/install
2. Configure gcloud CLI:
   ```bash
   gcloud config configurations create jetblue
   gcloud config set project [YOUR_PROJECT_ID]
   gcloud config set compute/region [YOUR_REGION]
   gcloud auth application-default login
   ```
3. Update ENVIRONMENT_CONFIG.json file with your GCP project id.
4. Use `.\00_launchpad\setup_gcp_environment.sh` script for setup GCP Storage bucket.



## How to work with code

First of all you should authorize on GCP Project

```bash
gcloud auth login
```