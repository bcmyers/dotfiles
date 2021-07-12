#!/usr/bin/env bash

# if not running interactively, return
[[ $- != *i* ]] && return

function is_in_path {
  builtin type -P "$1" &> /dev/null
}

# platform-specific
platform=$(uname)
prompt_color="yellow"
if [[ $platform == "Darwin" ]] ; then
    alias hide="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"
    alias show="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
    [ -r "/usr/local/etc/profile.d/bash_completion.sh" ] && source "/usr/local/etc/profile.d/bash_completion.sh"
    export SHELL=/usr/local/bin/bash
    prompt_color="blue"
else
    alias open="xdg-open"
fi

# basic
alias c=clear
alias ls="ls -al"
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PAGER=less
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

# rust
if [[ -d "$HOME/.cargo" ]]; then
    source "$HOME/.cargo/env"
    alias cb="cargo build"
    alias cc="cargo check"
    alias cr="cargo run"
    alias ct="cargo test"
fi

# prompt
prompt_command() {
    local exit="$?"
    is_in_path prompt
    if [[ "$?" -eq 0 ]]; then
        if [[ $exit == "0" ]]; then
            PS1="$(prompt --color="bright $prompt_color")\n$ "
        else
            PS1="$(prompt --color="bright red")\n$ "
        fi
    else
        PS1="$exit \u@\H \w\n$ "
    fi
}
PROMPT_COMMAND=prompt_command

# bat
is_in_path bat && alias cat=bat

# bazelisk
is_in_path bazelisk && alias bazel=bazelisk

# exa
is_in_path exa
if [[ "$?" -eq 0 ]]; then
    alias ls="exa -agl --color=always"
    alias tree="exa -aT --color=always --git-ignore"
fi

# deno
if [[ -d "$HOME/.deno" ]]; then
    export DENO_INSTALL="$HOME/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"
fi

# git
is_in_path git
if [[ "$?" -eq 0 ]]; then
    alias gd="git diff -- :/ ':(exclude,top)*Cargo.lock'"
    alias gl="git log --decorate --graph --oneline"
fi

# go
if [[ -d "$HOME/go" ]]; then
    export GOBIN=$HOME/go/bin
    export GOPATH=$HOME/go
    export PATH=$GOBIN:$PATH
fi

# gpg
# is_in_path gpg
# if [[ "$?" -eq 0 ]]; then
#     GPT_TTY=$(tty)
#     export GPG_TTY
#     SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
#     export SSH_AUTH_SOCK
#     gpgconf --launch gpg-agent
# fi

# jenv
if [[ -d "$HOME/.jenv" ]]; then
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
fi

# kubetl
is_in_path kubectl && alias k=kubectl

# nvim
is_in_path nvim
if [[ "$?" -eq 0 ]]; then
    export EDITOR=nvim
    export VISUAL=nvim
    # export PATH="$HOME/local/nvim/bin:$PATH"
fi

# nvm
[[ -d "$HOME/.nvm" ]] && export NVM_DIR="$HOME/.nvm"
[[ -s "/usr/local/opt/nvm/nvm.sh" ]] && source "/usr/local/opt/nvm/nvm.sh"
[[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ]] && source "/usr/local/opt/nvm/etc/bash_completion.d/nvm"

# npm
NPM_PACKAGES="${HOME}/.config/npm" # TODO: Make this directory if it doesn't exist
export PATH="$PATH:$NPM_PACKAGES/bin"
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"

# pipenv
is_in_path pipenv
[[ "$?" -eq 0 ]] && eval "$(pipenv --completion)"

# pipx
eval "$(register-python-argcomplete pipx)"
export PATH="$PATH:$HOME/.local/bin"

# pyenv and pyenv-virtualenv
if [[ -d "$HOME/.pyenv" ]]; then
    eval "$(pyenv init -)" > /dev/null 2>&1
    completions="$(pyenv root)/completions/pyenv.bash"
    [[ -r $completions ]] && source $completions
    mkdir -p $(pyenv root)/cache
    eval "$(pyenv virtualenv-init -)"
fi

# ripgrep
is_in_path rg && alias grep=rg

# yarn
is_in_path yarn
[[ "$?" -eq 0 ]] && export PATH="$(yarn global bin):$PATH"

# Other
set -o vi
[[ -d $HOME/bin ]] && export PATH=$HOME/bin:$PATH
[[ -r ~/.bash_secret ]] && source ~/.bash_secret

export FZF_TMUX_OPTS="-p"
export FZF_CTRL_R_OPTS="--reverse --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

source <(kubectl completion bash)

alias luamake=/Users/bcmyers/opt/lua-language-server/3rd/luamake/luamake
