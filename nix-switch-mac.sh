#!/usr/bin/env bash

set -euo pipefail

exec sudo nix \
  --extra-experimental-features "nix-command flakes" \
  run '.#darwin-rebuild' -- \
  switch --flake '.#mac' "$@"
