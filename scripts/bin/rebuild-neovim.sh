#!/usr/bin/env bash

set -eux

cd ~/opt/neovim

make distclean

git pull

make CMAKE_BUILD_TYPE=Release
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$HOME/bin/nvim install


