terraform {
  backend "s3" {}

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.60.0"
    }
  }
}

provider "databricks" {} # dev workspace
