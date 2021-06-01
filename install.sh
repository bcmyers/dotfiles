#!/usr/bin/env bash

# Note: Other useful arguments: -D, --adopt

mkdir -p ~/bin
mkdir -p ~/log

platform=$(uname)
if [[ $platform == "Darwin" ]] ; then
    stow -v --target ~ --no-folding gpg-macos
    stow -v --target ~ --no-folding nvim-macos
    stow -v --target ~ --no-folding scripts-macos
else
    stow -v --target ~ --no-folding gpg-linux
    stow -v --target ~ --no-folding nvim-linux
    stow -v --target ~ --no-folding scripts-linux
fi

stow -v --target ~ alacritty
stow -v --target ~ bash
stow -v --target ~ git
stow -v --target ~ --no-folding gpg
stow -v --target ~ --no-folding nvim
stow -v --target ~ --no-folding pyenv
stow -v --target ~ --no-folding scripts
stow -v --target ~ tmux
