#!/usr/bin/env bash
# Guardrail 2: one pull request holds an environment (for example QA) until it merges or closes.
# The lock is a small JSON file next to the Terraform state in S3.
#
#   env-lock.sh acquire <lock-name> <pr-number>   fail if another open PR holds it
#   env-lock.sh release <lock-name> <pr-number>   release if this PR holds it
#   env-lock.sh force-release <lock-name>         used after a merge to main
#
# Needs: LOCK_BUCKET, GH_TOKEN, GITHUB_REPOSITORY. Run inside a concurrency group per lock.
set -euo pipefail
action=$1; name=$2; pr=${3:-}
key="s3://${LOCK_BUCKET}/locks/${name}.json"

holder() { aws s3 cp "$key" - 2>/dev/null | jq -r '.pr // empty' || true; }
is_open() { [ "$(gh pr view "$1" --repo "$GITHUB_REPOSITORY" --json state -q .state 2>/dev/null)" = "OPEN" ]; }

case "$action" in
  acquire)
    current=$(holder)
    if [ -n "$current" ] && [ "$current" != "$pr" ] && is_open "$current"; then
      echo "::error::${name} is held by PR #${current}. Wait until it merges or closes, then re-run."
      exit 1
    fi
    jq -n --arg pr "$pr" --arg sha "${GITHUB_SHA:-}" --arg at "$(date -u +%FT%TZ)" '{pr:$pr, sha:$sha, at:$at}' | aws s3 cp - "$key"
    echo "PR #${pr} now holds ${name}."
    ;;
  release)
    [ "$(holder)" = "$pr" ] && aws s3 rm "$key" && echo "Released ${name}." || echo "PR #${pr} does not hold ${name}."
    ;;
  force-release)
    aws s3 rm "$key" >/dev/null 2>&1 || true
    echo "Released ${name}."
    ;;
  *) echo "usage: env-lock.sh acquire|release|force-release <lock-name> [pr]"; exit 2 ;;
esac
