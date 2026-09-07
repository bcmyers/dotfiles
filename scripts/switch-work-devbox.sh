#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "switch-work-devbox must run on Linux" >&2
  exit 1
fi

if [[ "$(id -u)" != "0" || "$(id -un)" != "root" || "${HOME-}" != "/root" ]]; then
  echo "switch-work-devbox must run as root with /root as HOME" >&2
  exit 1
fi

export USER=root

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

if [[ -n "$(git status --porcelain --untracked-files=normal)" ]]; then
  echo "switch-work-devbox requires a clean checkout of a reviewed revision" >&2
  exit 1
fi

if git symbolic-ref --quiet HEAD >/dev/null; then
  echo "switch-work-devbox requires detached HEAD at a reviewed commit" >&2
  exit 1
fi

reviewed_revision="$(git rev-parse --verify 'HEAD^{commit}')"
if [[ ! "$reviewed_revision" =~ ^[0-9a-f]{40}$ ]]; then
  echo "could not resolve the reviewed devbox revision" >&2
  exit 1
fi

printf 'Activating reviewed devbox revision %s\n' "$reviewed_revision"

exec ./scripts/nix-flake.sh run .#home-manager -- \
  -b home-manager-backup \
  --flake ".#\"${target}\"" \
  switch "$@"
