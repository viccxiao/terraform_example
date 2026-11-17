terraform {
  # Partial config. CI passes bucket and key, for example key=platform-infra/catalogs.tfstate
  backend "s3" {}

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.60.0"
    }
  }
}

# Auth comes from the environment (DATABRICKS_HOST, DATABRICKS_CLIENT_ID,
# DATABRICKS_AUTH_TYPE=github-oidc in CI). Needs metastore admin rights.
provider "databricks" {}
