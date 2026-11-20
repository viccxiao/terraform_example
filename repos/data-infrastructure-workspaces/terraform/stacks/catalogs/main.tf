resource "databricks_catalog" "this" {
  for_each = var.catalogs

  name           = each.key
  storage_root   = each.value.storage_root
  comment        = each.value.comment
  isolation_mode = "ISOLATED" # only visible in workspaces bound below
}

resource "databricks_workspace_binding" "this" {
  for_each = { for b in var.bindings : "${b.catalog}@${b.workspace}" => b }

  securable_name = databricks_catalog.this[each.value.catalog].name
  securable_type = "catalog"
  workspace_id   = var.workspace_ids[each.value.workspace]
  binding_type   = each.value.read_only ? "BINDING_TYPE_READ_ONLY" : "BINDING_TYPE_READ_WRITE"
}

# Everyone can browse catalogs. Schema-level grants (team-spaces) decide what they can read or write.
resource "databricks_grant" "use_catalog" {
  for_each   = var.catalogs
  catalog    = databricks_catalog.this[each.key].name
  principal  = "account users"
  privileges = ["USE_CATALOG"]
}

# CI creates a schema per pull request in dev (dev.pr_123) and drops it when the PR closes.
resource "databricks_grant" "bundle_ci_dev" {
  catalog    = databricks_catalog.this["dev"].name
  principal  = var.bundle_ci_service_principal
  privileges = ["USE_CATALOG", "CREATE_SCHEMA"]
}
