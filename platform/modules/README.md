# modules

Shared modules, released with a version tag (for example `modules/v1.4.0`) and pinned by every caller.

| Module | Status |
|---|---|
| `team_space` | New. Schemas and grants for one team, driven by `team-spaces/teams/<team>/space.yaml` |
| `databricks_workspace`, `databricks_catalog`, `glue_federation`, `databricks_lakehouse_federation`, `databricks_delta_share*`, `databricks_external_export_volume`, `databricks_dbt_exports_to_s3`, `databricks_sql_endpoint` | Move here unchanged from today's workspaces repo |
| `databricks_job`, `databricks_notebook`, `databricks_workspace_file`, `databricks_delta_table`, `databricks_dashboard`, `databricks_app` | Retire as products move to Asset Bundles |
| `delta_table_maintenance_job` | Review: Predictive Optimization may replace it |
| `databricks_obo_token` | Review: use service principal OAuth instead |
