terraform {
  # Own state per environment: CI passes key=smart-tags/<env>.tfstate
  backend "s3" {}

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.113.0, < 2.0.0"
    }
  }
}

provider "databricks" {}

variable "environment" {
  description = "dev, qa or prod. Set by CI."
  type        = string
}

locals {
  project = yamldecode(file("${path.module}/project.yaml"))
  catalog = local.project.catalogs[var.environment]

  schemas = [
    for s in local.project.schemas : {
      catalog = local.catalog
      name    = s.name
      comment = try(s.comment, "")
      readers = try(s.readers, [])
      tags    = try(s.tags, {})
    } if contains(try(s.environments, ["dev", "qa", "prod"]), var.environment)
  ]
}

module "project_space" {
  # Pinned version of the platform module, so platform changes never break this project mid-day:
  # source = "git::https://github.com/<org>/data-infrastructure-workspaces.git//terraform/modules/project_space?ref=modules/v1.4.0"
  source = "../../data-infrastructure-workspaces/terraform/modules/project_space"

  project          = local.project.project
  owners_group     = local.project.owners_group
  schemas          = local.schemas
  compute_policies = try(local.project.compute_policies, [])
}

output "deploy_service_principal_application_id" {
  value = module.project_space.deploy_service_principal_application_id
}
