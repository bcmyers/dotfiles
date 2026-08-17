#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "switch-work-devbox must run on Linux" >&2
  exit 1
fi

if [[ "$(id -u)" != "0" || "$HOME" != "/root" ]]; then
  echo "switch-work-devbox must run as root with /root as HOME" >&2
  exit 1
fi

exec ./scripts/nix-flake.sh run .#home-manager -- \
  -b home-manager-backup \
  --flake '.#"root@work-devbox"' \
  switch "$@"
