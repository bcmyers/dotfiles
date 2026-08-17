#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "build-work-devbox must run on Linux" >&2
  exit 1
fi

case "$(uname -m)" in
  aarch64 | arm64)
    target="root@work-devbox-aarch64-linux"
    ;;
  x86_64)
    target="root@work-devbox-x86_64-linux"
    ;;
  *)
    echo "unsupported work devbox architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

exec ./scripts/nix-flake.sh build ".#homeConfigurations.\"${target}\".activationPackage" "$@"
