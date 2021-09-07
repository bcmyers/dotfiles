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
export CPPFLAGS=-I/usr/local/opt/openssl@1.1/include
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LDFLAGS=-L/usr/local/opt/openssl@1.1/lib
export LC_ALL=en_US.UTF-8
export PAGER=less
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

# rust
if [[ -d "$HOME/.cargo" ]]; then
    source "$HOME/.cargo/env"
    alias cb="cargo build"
    alias cc="cargo clippy"
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
alias cat=bat

# bazelisk
alias bazel=bazelisk

# exa
is_in_path exa
if [[ "$?" -eq 0 ]]; then
    ls="exa -agl --color=always"
    tree="exa -aT --color=always --git-ignore"
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
is_in_path gpg
if [[ "$?" -eq 0 ]]; then
    gpg-connect-agent /bye > /dev/null 2>&1
    GPG_TTY=$(tty)
    export GPG_TTY
fi

# fzf
[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
export FZF_TMUX_OPTS="-p"
export FZF_CTRL_R_OPTS="--reverse --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"



# jenv
if [[ -d "$HOME/.jenv" ]]; then
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
fi

# k8s
alias k="kubectl"
alias kg="k get all"
alias kgp="k get pods"
alias kdp="k describe pods"
alias klogs="k logs -c app"
alias kc="k config"
alias kcontext="kc use-context"
alias knamespace="kc set-context --current --namespace"
alias kaf="k apply -f"

source <(kubectl completion bash)

function kgetcontext() {
    kubectl config get-contexts
}

function kusecontext() {
    kubectl config use-context "$1"
}

function kusenamespace() {
    kubectl config set-context --current "--namespace=$1"
}

# nvim
is_in_path nvim
if [[ "$?" -eq 0 ]]; then
    export EDITOR=nvim
    export VISUAL=nvim
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
if [[ "$?" -eq 0 ]]; then
    eval "$(pipenv --completion)"
fi

# pipx
eval "$(register-python-argcomplete pipx)"
export PATH="$PATH:$HOME/.local/bin"

# pyenv, pyenv-virtualenv, and pyenv-virtualenvwrapper
if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PYENV_SHELL=bash
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv init --path)"
    eval "$(pyenv virtualenv-init -)"
    export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
    export WORKON_HOME="$HOME/.virtualenvs"
    pyenv virtualenvwrapper_lazy
fi

# ripgrep
alias grep=rg

# yarn
is_in_path yarn
if [[ "$?" -eq 0 ]]; then
    export PATH="$(yarn global bin):$PATH"
fi

# Other
set -o vi
[[ -d $HOME/bin ]] && export PATH=$HOME/bin:$PATH
[[ -r ~/.bash_secret ]] && source ~/.bash_secret
