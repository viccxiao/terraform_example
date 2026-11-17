# team-spaces

Self-service layer. Each team owns one folder under `teams/` with a `space.yaml`.

- A change to `teams/<team>/space.yaml` is approved by that team's CODEOWNERS, not by the platform team.
- CI runs `terraform plan` on the PR and `apply` on merge, with one state file per team (`team-spaces/<team>.tfstate`). Teams never lock each other.
- Need a new catalog, workspace or compute policy? That is a platform-infra change instead.
