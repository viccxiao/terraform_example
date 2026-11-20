#!/usr/bin/env bash
# Guardrail 1: refuse to apply a branch that is missing work already merged to main.
# Run after actions/checkout with fetch-depth: 0.
set -euo pipefail
git fetch --quiet origin main
if git merge-base --is-ancestor origin/main HEAD; then
  echo "Up to date with main."
else
  echo "::error::This branch is behind main. Rebase or merge main, then re-run. Applying it would undo merged work."
  exit 1
fi
