output "deploy_service_principal_application_id" {
  description = "Use this as DATABRICKS_CLIENT_ID in the team's CI, with a GitHub OIDC federation policy."
  value       = databricks_service_principal.deploy.application_id
}

output "schemas" {
  value = keys(databricks_schema.this)
}
