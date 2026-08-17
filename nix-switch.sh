#!/usr/bin/env bash

set -euo pipefail

exec sudo nixos-rebuild switch --flake ".#thinkpad" "$@"
