#!/usr/bin/env bash

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

gitleaks_bin="$(./scripts/ensure-gitleaks.sh)"

"$gitleaks_bin" --no-banner --redact git .
"$gitleaks_bin" --no-banner --redact dir .
