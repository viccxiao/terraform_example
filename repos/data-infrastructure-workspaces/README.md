# data-infrastructure-workspaces (platform)

Slimmed down to shared platform infrastructure. Product work moves to project repos such as `smart-tags-databricks`.

```
terraform/
  backend/        dev / qa / prod backend files (as today). State key now includes the stack
  modules/        your existing modules, versioned (tags like modules/v1.4.0), plus project_space
  stacks/
    catalogs/     catalogs, external locations, workspace bindings      own state per env
    compute/      SQL warehouses, compute policies                       own state per env
    sharing-federation/  Delta Sharing, Glue and Lakehouse federation, Lakebase
.github/workflows/terraform.yml   calls the shared workflow, with the four guardrails
```

Changes here are weekly, reviewed by the platform team. Projects never need a PR here for routine work.
