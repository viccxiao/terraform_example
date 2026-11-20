# workflows (shared)

The one reusable Terraform workflow that every repo calls, with four guardrails added on apply.

| Guardrail | Stops |
|---|---|
| 1. Branch must be up to date with `main` | An older branch undoing merged work |
| 2. Environment lock (`scripts/env-lock.sh`) | Two PRs taking turns overwriting QA. Replaces "tell each other in chat" |
| 3. Apply the saved plan | Applying something different from what was reviewed |
| 4. Destroys flagged in the run summary | Deleting someone else's resources without noticing |

Your existing checks (Lint, Format, Trivy, Docs, SonarQube) and the approval buttons (GitHub Environments) stay as they are.
