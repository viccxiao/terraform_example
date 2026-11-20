locals {
  schemas = { for s in var.schemas : "${s.catalog}.${s.name}" => s }

  write_privileges = [
    "USE_SCHEMA", "SELECT", "MODIFY", "EXECUTE",
    "CREATE_TABLE", "CREATE_MATERIALIZED_VIEW", "CREATE_FUNCTION",
    "CREATE_VOLUME", "READ_VOLUME", "WRITE_VOLUME",
  ]
  read_privileges = ["USE_SCHEMA", "SELECT", "EXECUTE", "READ_VOLUME"]

  catalogs = toset([for s in var.schemas : s.catalog])
}

# One deploy identity per project. CI uses it (via OIDC) to deploy bundles to qa and prod.
resource "databricks_service_principal" "deploy" {
  display_name = "sp-${var.project}-deploy"
}

resource "databricks_schema" "this" {
  for_each = local.schemas

  catalog_name = each.value.catalog
  name         = each.value.name
  comment      = each.value.comment
  properties   = merge({ owner_project = var.project }, each.value.tags)
}

# Authoritative per schema: only this project's state manages grants on its own schemas.
# This is what stops one project writing into another project's tables.
resource "databricks_grants" "schema" {
  for_each = local.schemas
  schema   = databricks_schema.this[each.key].id

  # The deploy service principal always writes.
  grant {
    principal  = databricks_service_principal.deploy.application_id
    privileges = local.write_privileges
  }

  # Humans write only in sandbox catalogs (dev, data_science). In qa and prod they read.
  grant {
    principal  = var.owners_group
    privileges = contains(var.sandbox_catalogs, each.value.catalog) ? local.write_privileges : local.read_privileges
  }

  # Downstream consumers, for example data science reading DE gold tables.
  dynamic "grant" {
    for_each = toset([for r in each.value.readers : r if r != var.owners_group])
    content {
      principal  = grant.value
      privileges = local.read_privileges
    }
  }
}

# Non-authoritative, so many projects can add themselves without overwriting catalog grants.
resource "databricks_grant" "catalog_use" {
  for_each   = local.catalogs
  catalog    = each.value
  principal  = databricks_service_principal.deploy.application_id
  privileges = ["USE_CATALOG"]
}

# Compute policies are owned by platform/stacks/compute. A project gets access by joining the
# policy's users group, which is a non-authoritative membership.
data "databricks_group" "policy_users" {
  for_each     = toset(var.compute_policies)
  display_name = "policy-${each.value}-users"
}

data "databricks_group" "owners" {
  count        = length(var.compute_policies) > 0 ? 1 : 0
  display_name = var.owners_group
}

resource "databricks_group_member" "policy" {
  for_each  = toset(var.compute_policies)
  group_id  = data.databricks_group.policy_users[each.key].id
  member_id = data.databricks_group.owners[0].id
}
