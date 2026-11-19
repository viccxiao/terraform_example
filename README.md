# Databricks Terraform + Asset Bundles: example structure

An example of how a Terraform setup like Zoopla's could be organised so that pull requests never clash, teams can self-serve, and products ship independently.

**Template only.** Hosts, IDs, buckets, groups and GitHub teams are placeholders. Nothing here has been applied.

## The idea in three lines

1. **Terraform owns the containers** (workspaces, catalogs, warehouses, schemas, grants). **Asset Bundles own the workloads** (jobs, notebooks, tables, MLflow, alerts).
2. **Pull requests plan, `main` applies.** Shared state is only ever changed from `main`.
3. **Every product PR gets its own copy** in `dev.pr_<number>`, deleted when the PR closes.

## Layout

```
platform/                      Shared infrastructure. Owner: platform team. Changes weekly.
  backend/                     dev / qa / prod backend files (same pattern as today)
  modules/                     Your existing modules move here, versioned. Plus team_space (new)
  stacks/
    catalogs/                  Catalogs + workspace bindings          own state per env
    compute/                   Warehouses + compute policies          own state per env
    sharing-federation/        Delta Sharing, Glue/Lakehouse federation, Lakebase

team-spaces/                   Schemas + grants. Owner: each team. Changes when a team needs a new schema.
  teams/data-engineering/space.yaml
  teams/data-science/space.yaml

products/                      One Asset Bundle per product. Owner: the product squad. Changes daily.
  smart-tags/                  Pilot: jobs, MLflow experiment, contract check
  search-listings/             Next, same shape

migration/                     How to move a product out of Terraform with no downtime
ci-examples/                   GitHub Actions: Stage 1 caller, reusable workflow sketch, bundle workflow
.github/CODEOWNERS             Who approves what
```

## Where today's files go

| Today (workspaces root) | Goes to |
|---|---|
| `catalogs.tf`, `volumes.tf`, external locations, storage credentials | `platform/stacks/catalogs` |
| `sql_warehouses.tf`, `clusters.tf` | `platform/stacks/compute` |
| Delta Sharing, `glue_federation`, Lakehouse federation, Lakebase | `platform/stacks/sharing-federation` |
| `schemas.tf`, grants | `team-spaces/teams/<team>/space.yaml` |
| `jobs_smart_tags_*`, `notebooks_smart_tags*`, `mlflow_smart_tags*`, `tables_smart_tags_*`, `alerts_smart_tags_*` | `products/smart-tags` |
| `*_image_tagger*`, `*_text_tagger*`, `*agent_harness*`, `*autoloader_search_listings*` | `products/<product>` |

## The plan

| Step | What | Where in this repo |
|---|---|---|
| 1 | PRs plan only, `main` applies, applies never cancelled | `ci-examples/terraform-stage1.yml` |
| 2 | Pilot: Smart Tags to a bundle, PR copies in `dev.pr_<n>` | `products/smart-tags`, `ci-examples/bundle.yml`, `migration/` |
| 3 | Other products, one at a time | `products/search-listings` |
| 4 | Split platform state, team self-service | `platform/stacks`, `team-spaces/` |
| 5 | Tidy up: OAuth instead of on-behalf-of tokens, one grants owner, Predictive Optimization | `platform/modules/README.md` |

## How team-spaces work

A team that needs a new schema edits **its own** `space.yaml` and opens a PR. Its own lead approves (CODEOWNERS). On merge, CI applies **only that team's** state (`team-spaces/<team>.tfstate`). No central queue, and teams never lock each other.

## Notes

- Workflows are in `ci-examples/` so they don't run against placeholders. Copy them to `.github/workflows/` to use them.
- `terraform validate` passes for every Terraform folder (Terraform 1.11, Databricks provider 1.113+). Not applied to a live workspace.
