#!/usr/bin/env bash

set -euo pipefail

if ! command -v nix >/dev/null 2>&1; then
  cat >&2 <<'EOF'
Nix is required but was not found.

Install Nix using the official instructions at:
https://nixos.org/download/
EOF
  exit 1
fi

exec nix \
  --extra-experimental-features "nix-command flakes" \
  run . -- \
  switch \
  -b home-manager-backup \
  --flake ".#bcmyers@linux" \
  "$@"
