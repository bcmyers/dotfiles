install: remove-ds-store
    #!/usr/bin/env bash

    # Note: Other useful arguments: -D, --adopt

    mkdir -p ~/.local/bin

    platform=$(uname)
    if [[ $platform == "Darwin" ]] ; then
        arch=$(uname -p)
        stow -v --target ~ --no-folding bash-macos
        stow -v --target ~ --no-folding gpg-macos
        stow -v --target ~ --no-folding scripts-macos
        stow -v --target ~ --no-folding spotifyd-macos
    else
        stow -v --target ~ --no-folding gpg-linux
        stow -v --target ~ --no-folding scripts-linux
    fi

    stow -v --target ~ bash
    stow -v --target ~ --no-folding gpg
    stow -v --target ~ nvim
    stow -v --target ~ --no-folding pyenv
    stow -v --target ~ --no-folding scripts
    stow -v --target ~ yarn

remove-ds-store:
    find . -name '.DS_Store' -type f -delete
