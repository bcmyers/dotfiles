#!/usr/bin/env bash

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

./scripts/nix-flake.sh run .#gitleaks -- --no-banner --redact git .
./scripts/nix-flake.sh run .#gitleaks -- --no-banner --redact dir .
