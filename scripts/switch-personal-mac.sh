#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "switch-personal-mac must run on macOS" >&2
  exit 1
fi

if [[ "$(id -un)" != "bcmyers" || "$HOME" != "/Users/bcmyers" ]]; then
  echo "switch-personal-mac must run as bcmyers with /Users/bcmyers as HOME" >&2
  exit 1
fi

exec sudo -H nix \
  --extra-experimental-features "nix-command flakes" \
  run '.#darwin-rebuild' -- \
  switch --flake '.#personal-mac' "$@"
