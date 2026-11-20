# Platform owns the policy and who can use it. Projects join the users group from their project space.
locals {
  policies = {
    "ds-large-memory" = {
      node_types  = ["r6id.2xlarge", "r6id.4xlarge"]
      max_workers = 8
      team_tag    = "data-science"
    }
  }
}

resource "databricks_group" "policy_users" {
  for_each     = local.policies
  display_name = "policy-${each.key}-users"
}

resource "databricks_cluster_policy" "this" {
  for_each = local.policies
  name     = each.key

  definition = jsonencode({
    "node_type_id"            = { type = "allowlist", values = each.value.node_types }
    "autoscale.max_workers"   = { type = "range", maxValue = each.value.max_workers }
    "autotermination_minutes" = { type = "range", minValue = 10, maxValue = 120, defaultValue = 60 }
    "custom_tags.team"        = { type = "fixed", value = each.value.team_tag }
    "data_security_mode"      = { type = "fixed", value = "USER_ISOLATION" }
  })
}

resource "databricks_permissions" "policy" {
  for_each          = local.policies
  cluster_policy_id = databricks_cluster_policy.this[each.key].id

  access_control {
    group_name       = databricks_group.policy_users[each.key].display_name
    permission_level = "CAN_USE"
  }
}
