terraform {
  # One state file per team: CI passes key=team-spaces/<team>.tfstate
  backend "s3" {}

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.113.0, < 2.0.0"
    }
  }
}

provider "databricks" {}

variable "team" {
  description = "Folder name under teams/. CI sets this from the changed path."
  type        = string
}

locals {
  space = yamldecode(file("${path.module}/teams/${var.team}/space.yaml"))
}

module "team_space" {
  # Pin a version so platform changes never break a team's plan mid-day.
  # In separate repos: source = "git::https://github.com/<org>/platform.git//modules/team_space?ref=v1.4.0"
  source = "../platform/modules/team_space"

  team             = local.space.team
  owners_group     = local.space.owners_group
  schemas          = local.space.schemas
  compute_policies = try(local.space.compute_policies, [])
}

output "deploy_service_principal_application_id" {
  value = module.team_space.deploy_service_principal_application_id
}
