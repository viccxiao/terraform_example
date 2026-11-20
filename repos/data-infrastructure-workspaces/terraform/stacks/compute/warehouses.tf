# Shared SQL warehouses stay in platform Terraform.
resource "databricks_sql_endpoint" "shared" {
  name                      = "shared-analytics"
  cluster_size              = "Small"
  max_num_clusters          = 2
  auto_stop_mins            = 10
  enable_serverless_compute = true

  tags {
    custom_tags {
      key   = "owner"
      value = "platform"
    }
  }
}
