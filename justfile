install:
    #!/usr/bin/env bash

    # Note: Other useful arguments: -D, --adopt

    mkdir -p ~/bin
    mkdir -p ~/log

    platform=$(uname)
    if [[ $platform == "Darwin" ]] ; then
        arch=$(uname -p)
        stow -v --target ~ --no-folding bash-macos
        stow -v --target ~ --no-folding scripts-macos
        stow -v --target ~ --no-folding spotifyd-macos
        if [[ $arch == "arm" ]]; then
          stow -v --target ~ --no-folding gpg-macos-aarch64
        else
          stow -v --target ~ --no-folding gpg-macos-x86_64
        fi
    else
        stow -v --target ~ --no-folding gpg-linux
        stow -v --target ~ --no-folding scripts-linux
    fi

    stow -v --target ~ alacritty
    stow -v --target ~ bash
    stow -v --target ~ git
    stow -v --target ~ --no-folding gpg
    stow -v --target ~ nvim
    stow -v --target ~ --no-folding pyenv
    stow -v --target ~ --no-folding scripts
    stow -v --target ~ tmux

remove-ds-store:
    find . -name '.DS_Store' -type f -delete
