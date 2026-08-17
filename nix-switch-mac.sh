#!/usr/bin/env bash

set -euo pipefail

# Authenticate before stopping the service that nix-darwin will replace.
sudo true

restore_homebrew_ollama=false
if command -v brew >/dev/null 2>&1 && brew list --formula ollama >/dev/null 2>&1; then
  brew services stop ollama
  restore_homebrew_ollama=true
fi

if ! sudo nix run '.#darwin-rebuild' -- switch --flake '.#mac'; then
  if $restore_homebrew_ollama; then
    brew services start ollama
  fi
  exit 1
fi
