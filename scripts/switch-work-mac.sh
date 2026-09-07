#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "switch-work-mac must run on macOS" >&2
  exit 1
fi

if [[ "$(id -un)" != "brian.myers" || "$HOME" != "/Users/brian.myers" ]]; then
  echo "switch-work-mac must run as brian.myers with /Users/brian.myers as HOME" >&2
  exit 1
fi

exec ./scripts/nix-flake.sh run .#home-manager -- \
  -b home-manager-backup \
  --flake '.#"brian.myers@work-mac"' \
  switch "$@"
