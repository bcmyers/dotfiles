#!/usr/bin/env bash

set -euo pipefail

if [[ ! -e /etc/NIXOS ]]; then
  cat >&2 <<'EOF'
This repository now manages the complete ThinkPad NixOS installation.

For a fresh installation, follow docs/install-thinkpad.md from a NixOS USB.
This helper only switches an already-installed NixOS system.
EOF
  exit 1
fi

exec ./nix-switch.sh "$@"
