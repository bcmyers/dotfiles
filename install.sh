#!/usr/bin/env bash

set -euo pipefail

NVIM_BRANCH=v0.10.1

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
  build-essential \
  curl \
  fzf \
  gettext \
  htop \
  libssl-dev \
  stow

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

export PATH="$HOME/.cargo/bin:$PATH"

cargo install \
  bat \
  cargo-update \
  eza \
  fd-find \
  just \
  ripgrep

if ! command -v nvim &> /dev/null; then
  (
    mkdir -p ~/opt
    cd ~/opt
    git clone --branch $NVIM_BRANCH --depth 1 https://github.com/neovim/neovim.git
    cd neovim
    make \
      CMAKE_BUILD_TYPE=Release \
      CMAKE_INSTALL_PREFIX=$HOME/.local \
      install
  )
fi

if ! command -v prompt &> /dev/null; then
  (
    mkdir -p ~/lib
    cd ~/lib
    git clone https://github.com/bcmyers/prompt.git
    cd prompt
    cargo install --root ~/.local --path .
  )
fi

stow -v --target ~ fish
stow -v --target ~ nvim
