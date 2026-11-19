terraform {
  backend "s3" {}

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.113.0, < 2.0.0"
    }
  }
}

provider "databricks" {} # one workspace per apply, chosen by CI
