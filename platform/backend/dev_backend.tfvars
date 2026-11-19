# Same pattern as today: one backend file per environment.
# The key now also includes the stack, so each stack has its own state.
# CI: terraform init -backend-config=../../backend/dev_backend.tfvars -backend-config="key=platform/<stack>/dev.tfstate"
bucket       = "<terraform-state-bucket>"
region       = "eu-west-2"
use_lockfile = true
