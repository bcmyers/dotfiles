install: remove-ds-store
    #!/usr/bin/env bash

    # Note: Other useful arguments: -D, --adopt

    mkdir -p ~/.local/bin

    system="$(uname -s)"
    if [[ $system == "Darwin" ]]; then
        machine="$(uname -m)"
        stow -v --target ~ --no-folding scripts-macos
        stow -v --target ~ --no-folding spotifyd-macos
        if [[ $machine == "x86_64" ]]; then
            stow -v --target ~ --no-folding gpg-macos
        elif [[ $machine == "arm64" ]]; then
            stow -v --target ~ --no-folding gpg-macos-aarch64
        else
            echo "Unsupported platform: $(uname -s)-$(uname -m)"
            exit 1
        fi
    elif [[ $system == "Linux" ]]; then
        stow -v --target ~ --no-folding gpg-linux
        stow -v --target ~ --no-folding scripts-linux
    else
        echo "Unsupported platform: $(uname-s)-$(uname -m)"
        exit 1
    fi

    stow -v --target ~ bash
    stow -v --target ~ --no-folding gpg
    stow -v --target ~ nvim
    stow -v --target ~ --no-folding pyenv
    stow -v --target ~ --no-folding scripts
    stow -v --target ~ yarn

    if [[ ! -d $HOME/.nix-profile ]]; then
        stow -v --target ~ alacritty
        stow -v --target ~ bash-without-nix
        stow -v --target ~ git
        stow -v --target ~ tmux
    fi

remove-ds-store:
    find . -name '.DS_Store' -type f -delete
