# db-gcp-poc

## Development environment setup

1. I recommend to use GCP Cloud Shell.
2. If you want to develop on local or remote machine. You will need to install next compoents
    2.1 Install `jq` It will be used for parsing of json config file in bash scripts https://jqlang.org/
    2.2 Install Google Cloud SDK (cli) https://cloud.google.com/sdk/docs/install
    2.3. Configure gcloud CLI:
        ```bash
        gcloud config configurations create jetblue
        gcloud config set project [YOUR_PROJECT_ID]
        gcloud config set compute/region [YOUR_REGION]
        gcloud auth application-default login
        ```
3. Clone github repository
```bash
gh repo clone DenysBabenko1984/db-gcp-poc
```
4. Update ENVIRONMENT_CONFIG.json file with your GCP project id.
5. Use `.\00_launchpad\setup_gcp_environment.sh` script for setup GCP project.
Script is not re-runnable.  Setup of environment could be implemented with Terraform.

## How to work with code

You should authorize on GCP Project

```bash
gcloud auth application-default login 
```