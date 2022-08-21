#!/usr/bin/env bash

# functions

function edit_dotfiles() {
  pushd "$HOME/dotfiles"
  nvim .
}
export edit_dotfiles

function edit_user_chrome() {
  pushd "$HOME/Library/Application Support/Firefox/Profiles/ouotagtz.default-release-1636802624234/chrome"
  nvim .
}
export edit_user_chrome

function is_in_path {
  builtin type -P "$1" &> /dev/null
}

function print_path() {
  echo -e "${PATH//:/\\n}"
}

function remove_from_path() {
  PATH=$(echo -n "$PATH" | awk -v RS=: -v ORS=: '$0 != "'"$1"'"' | sed 's/:$//')
  export PATH
}

function ports() {
  sudo lsof -P -i TCP -s TCP:LISTEN
}

function remove_ds_store() {
  find . -name '.DS_Store' -type f -delete
}

export EDITOR=vi
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PAGER="less -r --use-color"
export VISUAL=vi

mkdir -p "${HOME}/.local/bin"
mkdir -p "${HOME}/.local/sbin"

platform="$(uname -s)-$(uname -m)"
prompt_color="blue"
usr_local="/usr/local"

if [[ $platform == Darwin-arm64 ]] && [[ $(sysctl -n sysctl.proc_translated) = "1" ]]; then
  platform="Darwin-x86_64"
fi

case "${platform}" in
Darwin-x86_64)
  echo "" > /dev/null
  ;;
Darwin-arm64)
  usr_local="/opt/homebrew"
  ;;
Linux-x86_64)
  echo "" > /dev/null
  ;;
Linux-arm64)
  echo "" > /dev/null
  ;;
*)
  echo "WARNING: unsupported platform"
  ;;
esac

export PATH="${HOME}/.local/bin:${usr_local}/bin:/usr/bin:/bin:${HOME}/.local/sbin:${usr_local}/sbin:/usr/sbin:/sbin"

case "$(uname -s)" in
Darwin)
  if [[ -e ${usr_local}/bin/bash ]]; then
    export SHELL="${usr_local}/bin/bash"
  fi
  if [[ -e ${usr_local}/opt/openssl@1.1 ]]; then
    export CPPFLAGS="-I${usr_local}/opt/openssl@1.1/include"
    export LDFLAGS="-L/${usr_local}/opt/openssl@1.1/lib"
    export OPENSSL_ROOT_DIR="${usr_local}/opt/openssl@1.1"
  fi
  if [[ -e ${usr_local}/opt/php@7.4 ]]; then
    export PATH="${usr_local}/opt/php@7.4/bin:$PATH"
    export PATH="${usr_local}/opt/php@7.4/sbin:$PATH"
  fi
  alias hide="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"
  alias show="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
  ;;
Linux)
  alias open="xdg-open"
  ;;
*)
  echo "WARNING: unsupported platform"
  ;;
esac

# nix
if [[ -d $HOME/.nix-profile/bin ]]; then
  export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
fi

# bash completion
[[ -r "${usr_local}/etc/profile.d/bash_completion.sh" ]] && source "${usr_local}/etc/profile.d/bash_completion.sh"

# basic
alias c=clear
alias ls="ls -al"

# rust
if [[ -d "$HOME/.cargo" ]]; then
  source "$HOME/.cargo/env"
  alias cb="cargo build"
  alias cc="cargo clippy --all"
  alias cr="cargo run"
  alias ct="cargo test"
fi

# prompt
prompt_command() {
  local exit="$?"
  if is_in_path prompt; then
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
if is_in_path bat; then
  alias cat=bat
fi

# bazelisk
if is_in_path bazelisk; then
  alias bazel="bazelisk"
fi

# branches
if is_in_path branches; then
  alias b=branches
fi

# exa
if is_in_path exa; then
  alias ls="exa -agl --color=always"
  alias tree="exa -aT --color=always --git-ignore"
fi

# deno
if [[ -d "$HOME/.deno" ]]; then
  export DENO_INSTALL="$HOME/.deno"
  export PATH="$PATH:$DENO_INSTALL/bin"
fi

# fzf
if is_in_path fzf; then
  # shellcheck disable=SC1090
  [[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
  export FZF_TMUX_OPTS="-p"
  export FZF_CTRL_R_OPTS="--reverse --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
fi

# git
if is_in_path git; then
  alias gd="git diff -- :/ ':(exclude,top)*Cargo.lock'"
  alias gf="git log --follow --date=short --pretty=format:'%C(bold blue)%ad%C(reset) %C(bold yellow)%p %h%C(reset) %s %C(bold red)%an%C(reset)' -- ."
  alias gl="git log --decorate --graph --oneline"

  function gff() {
    if [[ -z $1 ]]; then
      echo -e "Missing argument"
      exit 1
    fi

    # shellcheck disable=SC2086
    git log \
      --follow \
      --date=short \
      --pretty=format:'%C(bold blue)%ad%C(reset) %C(bold yellow)%p %h%C(reset) %s %C(bold red)%an%C(reset)' \
      -- $1
  }
fi

# golang
if is_in_path go; then
  go_bin="$HOME/go/bin/go1.16.7"
  if [[ -x $go_bin ]]; then
    GOROOT=$("$go_bin" env GOROOT)
    export GOROOT
    export PATH="$GOROOT/bin:$HOME/go/bin:$PATH"
  fi
fi

# gpg
if is_in_path gpgconf; then
  unset SSH_AGENT_PID
  SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  export SSH_AUTH_SOCK
  GPG_TTY=$(tty)
  export GPG_TTY
  gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1
fi

# jenv
if [[ -d "$HOME/.jenv" ]]; then
  export PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"
fi

# just
if is_in_path just; then
  alias j=just
  # shellcheck disable=SC1090
  source <(just --completions bash)
  complete -F _just -o bashdefault -o default j
fi

# k8s
if is_in_path kubectl; then
  alias k="kubectl"
  alias kg="k get all"
  alias kgp="k get pods"
  alias kdp="k describe pods"
  alias klogs="k logs -c app"
  alias kc="k config"
  alias kcontext="kc use-context"
  alias knamespace="kc set-context --current --namespace"
  alias kaf="k apply -f"
  function kgetcontext() {
    kubectl config get-contexts
  }
  function kusecontext() {
    kubectl config use-context "$1"
  }
  function kusenamespace() {
    kubectl config set-context --current "--namespace=$1"
  }
  # shellcheck disable=SC1090
  source <(kubectl completion bash)
fi

# nvim
if [[ -d $HOME/.local/nvim ]]; then
  export PATH="$HOME/.local/nvim/bin:$PATH"
fi
if is_in_path nvim; then
  export EDITOR=nvim
  export VISUAL=nvim
  alias lg="nvim . +'Telescope live_grep'"
  alias nvim="nvim --startuptime /tmp/nvim-startuptime"
fi

# nvm
if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$HOME/.nvm/nvm.sh" ]] && source "$HOME/.nvm/nvm.sh"
  [[ -s "$HOME/.nvm/bash_completion" ]] && source "$HOME/.nvm/bash_completion"
fi

# npm
npm_dir="${HOME}/.config/npm"
if [[ -d $npm_dir ]]; then
  export PATH="$PATH:$npm_dir/bin"
  export MANPATH="${MANPATH-$(manpath)}:$npm_dir/share/man"
fi

# pipenv
if is_in_path pipenv; then
  eval "$(pipenv --completion)"
fi

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
if is_in_path rg; then
  alias grep=rg
fi

# yarn
if is_in_path yarn; then
  mkdir -p "$HOME/.yarn"
  if [[ $(yarn global bin) != "$HOME/.yarn/bin" ]]; then
    yarn config set prefix "$HOME/.yarn"
  fi
  export PATH="$HOME/.yarn/bin:$PATH"
fi

# zoxide
if is_in_path zoxide; then
  export _ZO_DATA_DIR="${HOME}/.local/share/zoxide"
  eval "$(zoxide init --cmd cd bash)"
fi

# Other
set -o vi

if [[ -e $HOME/.bash_secret ]]; then
  source "$HOME/.bash_secret"
fi
