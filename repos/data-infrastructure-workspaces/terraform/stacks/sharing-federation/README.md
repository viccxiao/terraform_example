# sharing-federation (placeholder)

Shared integrations move here from today's workspaces root, as their own stack and state:

- Delta Sharing shares and recipients (`databricks_delta_share`, `databricks_delta_share_recipient` modules)
- Glue and Lakehouse federation (`glue_federation`, `databricks_lakehouse_federation` modules)
- Lakebase instances and catalogs
- Export volumes (`databricks_external_export_volume`, `databricks_dbt_exports_to_s3`)

Your existing modules move into `platform/modules/` unchanged. Only the root files that call them move here.
