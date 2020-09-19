#!/usr/bin/env bash

set -eux

yay -Syyuu
yay -Yc
yay -Sc
rustup self update
rustup update
cargo install-update --all
sudo journalctl --vacuum-size=1G
sudo updatedb
