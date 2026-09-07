#!/usr/bin/env bash

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

git_dir="$(git rev-parse --absolute-git-dir)"
out_link="$git_dir/dotfiles-gitleaks"
revision_file="$git_dir/dotfiles-gitleaks-revision"

# Read only the lock file; never import a candidate working tree into the store
# before it has passed secret scanning.
nixpkgs_revision="$(
  nix --extra-experimental-features "nix-command flakes" eval --impure --raw --expr \
    'let lock = builtins.fromJSON (builtins.readFile ./flake.lock); in lock.nodes."nixpkgs-unstable".locked.rev'
)"

if [[ ! "$nixpkgs_revision" =~ ^[0-9a-f]{40}$ ]]; then
  echo "flake.lock does not contain a valid pinned nixpkgs-unstable revision" >&2
  exit 1
fi

cached_revision=""
if [[ -r "$revision_file" ]]; then
  cached_revision="$(< "$revision_file")"
fi

if [[ ! -x "$out_link/bin/gitleaks" || "$cached_revision" != "$nixpkgs_revision" ]]; then
  nix --extra-experimental-features "nix-command flakes" build \
    --out-link "$out_link" \
    "github:NixOS/nixpkgs/${nixpkgs_revision}#gitleaks"
  printf '%s\n' "$nixpkgs_revision" > "$revision_file"
fi

printf '%s\n' "$out_link/bin/gitleaks"
