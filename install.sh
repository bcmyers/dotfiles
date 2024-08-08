#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
  curl \
  libssl-dev \
  neovim \
  stow

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

export PATH="$HOME/.cargo/bin:$PATH"

cargo install eza ripgrep

echo "Hello world" > /tmp/foo.txt
