# smart-tags-databricks (project repo, pilot)

Everything Smart Tags owns, in one place: its Unity Catalog space, its workloads and its own CI/CD.
Image, floor plan and text taggers are one project.

```
terraform/
  project.yaml        schemas, readers, compute policy for Smart Tags
  main.tf             calls the platform's project_space module (pinned version)
  backend/            own state per environment: smart-tags/<env>.tfstate
databricks.yml        Asset Bundle: targets dev (personal), pr, qa, prod
resources/
  taggers.yml         image, floor plan and text tagger jobs
  jobs.yml            golden set build + weekly review
  mlflow.yml          MLflow experiment
src/                  job code (was notebooks/ in the workspaces repo)
.github/workflows/
  terraform.yml       project space: plan on PR, approved apply with locks, main resets dev and QA
  bundle.yml          PR copy in dev.pr_<n>, approved QA deploy (locked), main -> QA -> prod
```

| Change | What happens |
|---|---|
| Edit a tagger or notebook | PR deploys an isolated copy to `dev.pr_<n>` automatically. Approve to deploy QA. Merge to ship to prod |
| New schema or reader | Edit `terraform/project.yaml`. Plans only Smart Tags' state. Smart Tags lead approves |
| Platform change needed (new catalog, policy) | PR in `data-infrastructure-workspaces` |
