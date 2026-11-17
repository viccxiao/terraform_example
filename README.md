# Databricks Terraform + Asset Bundles template

Example structure for isolated development, self-service infrastructure and safe sharing between data engineering and data science on Databricks (AWS).

**This is a template.** Hostnames, workspace IDs, S3 paths, group names and GitHub teams are placeholders. Nothing here has been applied.

## Principles

1. **Terraform owns the containers, bundles own the workloads.** Terraform creates catalogs, schemas, grants, service principals and policies. Jobs, pipelines and notebooks are deployed by Databricks Asset Bundles.
2. **Isolate by schema, not by workspace.** Every PR gets `dev.pr_<number>`, every person gets a personal target, every data science project gets `ds.ds_<project>`.
3. **One writer per table.** Each schema is owned by one team. Consumers get `SELECT` only, enforced by Unity Catalog.
4. **Self-service with guardrails.** Teams change their own `space.yaml`, approved by their own CODEOWNERS, applied by CI with one state file per team.

## Layout

In practice these are three separate repos. They sit in one repo here so the example is easy to read.

```
platform-infra/                 Owner: platform team. Changes weekly.
  modules/team_space/           Shared module, versioned and pinned by team-spaces
  stacks/catalogs/              dev, ds, stg, prod catalogs + workspace bindings (prod is read-only in dev)
  stacks/policies/              Compute policies and their users groups

team-spaces/                    Owner: each team via CODEOWNERS. Changes daily.
  main.tf                       Loads teams/<team>/space.yaml into the team_space module
  teams/data-engineering/       Publishes prod.listings_gold as a contract, readers listed
  teams/data-science-pricing/   ds_pricing (prototype) + stg/prod ds_pricing (service principal writes only)

project-example/                Owner: the squad. Changes many times a day.
  databricks.yml                Targets: dev, pr, stg, prod. Catalog and schema are variables
  resources/pricing_job.yml     Triggered when DE's gold table updates
  src/check_contract.py         Fails fast if DE's table drops or changes a column this project uses
  src/build_features.py         Reads DE gold, writes to its own schema

ci-examples/terraform.yml       Plan on PR, apply on merge, one job + state per changed stack or team
ci-examples/bundle.yml          PR -> dev.pr_<n>, close -> destroy, main -> stg, tag -> prod
.github/CODEOWNERS              Who approves what
```

## How a change flows

| Change | Where | Who approves | Platform team involved? |
|---|---|---|---|
| New job, pipeline or notebook | project repo | Squad | No |
| New schema, reader or grant | `team-spaces/teams/<team>/space.yaml` | Team lead | No |
| Use a bigger compute policy | `compute_policies:` in `space.yaml` | Team lead | No |
| New catalog, workspace or policy | `platform-infra/` | Platform team | Yes |
| Change to the shared module | `platform-infra/modules/` | Platform team | Yes, released as a new version |

## How DE and DS avoid clashing

- DE owns `prod.listings_gold`. DS is listed as a reader, so it can `SELECT` but never write.
- DS writes only to `ds.ds_pricing*` while prototyping, and to `stg/prod.ds_pricing` through its deploy service principal.
- The prod catalog is bound **read-only** to the dev workspace, so DS prototypes on real data with no copies and no risk.
- `check_contract.py` runs first in every DS job, so a breaking DE change fails loudly instead of silently producing bad features.
- DS jobs use a table update trigger on DE's table, so they run after DE refreshes, not on a clock.
- Breaking changes to a contract table ship as a new version (`listings_gold_v2` or a view), with the old one kept for an agreed period.

## Getting started

0. The GitHub Actions workflows live in `ci-examples/` so they don't run against placeholders. Copy them to `.github/workflows/` once the steps below are done.

1. Replace placeholders in `platform-infra/stacks/catalogs/terraform.tfvars.example` and `project-example/databricks.yml`.
2. Create an S3 bucket for Terraform state and a GitHub OIDC role for it (`TF_STATE_ROLE_ARN`).
3. Create service principals with GitHub OIDC federation policies, and set the repo variables used in the workflows (`DATABRICKS_*_HOST`, `TF_PLATFORM_SP_CLIENT_ID`, `BUNDLE_CI_SP_CLIENT_ID`, `TEAM_DEPLOY_SP_CLIENT_ID`).
4. Apply `platform-infra/stacks/catalogs`, then `stacks/policies`, then each team.
5. Personal dev: `cd project-example && databricks bundle deploy` (deploys to your own prefixed copy).

## Notes and caveats

- `databricks_grants` on schemas is authoritative, so each schema's grants must live in exactly one team's state. Catalog and group membership use non-authoritative resources so teams never overwrite each other.
- Cluster policy permissions are owned by platform-infra. Teams get access by joining `policy-<name>-users`.
- Validated with `terraform validate` (Databricks provider >= 1.60). Not applied against a live workspace.
