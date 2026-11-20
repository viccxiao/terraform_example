terraform {
  # Partial config. CI passes bucket and key, for example key=platform/catalogs/dev.tfstate
  backend "s3" {}

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.113.0, < 2.0.0"
    }
  }
}

# Auth comes from the environment (DATABRICKS_HOST, DATABRICKS_CLIENT_ID,
# DATABRICKS_AUTH_TYPE=github-oidc in CI). Needs metastore admin rights.
provider "databricks" {}
