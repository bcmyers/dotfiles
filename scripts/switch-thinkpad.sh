#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "switch-thinkpad must run on Linux" >&2
  exit 1
fi

if [[ "$(id -un)" != "bcmyers" ]]; then
  echo "switch-thinkpad must run as bcmyers" >&2
  exit 1
fi

if [[ "$(hostname -s)" != "thinkpad" ]]; then
  echo "switch-thinkpad must run on the thinkpad host" >&2
  exit 1
fi

exec sudo nix \
  --extra-experimental-features "nix-command flakes" \
  run ".#nixos-rebuild" -- \
  switch --flake ".#thinkpad" "$@"
