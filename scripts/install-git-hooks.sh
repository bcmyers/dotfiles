#!/usr/bin/env bash

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

gitleaks_bin="$(./scripts/ensure-gitleaks.sh)"
git config --local core.hooksPath .githooks

printf 'Installed the secret-scanning hook with %s\n' "$gitleaks_bin"
