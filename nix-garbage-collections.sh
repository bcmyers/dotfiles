#!/usr/bin/env bash

set -euo pipefail

nix \
  --extra-experimental-features "nix-command flakes" \
  run . -- \
  expire-generations "-30 days"

exec nix \
  --extra-experimental-features "nix-command flakes" \
  store gc
