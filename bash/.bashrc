#!/usr/bin/env bash

function error() {
  if [[ ! -z $1 ]]; then
    echo -e "$1"
  fi
  exit 1
}

function is_in_path {
  builtin type -P "$1" &> /dev/null
}

export EDITOR=vi
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PAGER=less
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export VISUAL=vi

mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/sbin

# platform-specific
case $(uname) in
  Darwin)
    case $(uname -p) in
      i386)
        local="/usr/local"
        prompt_color="blue"
        ;;
      arm)
        prompt_color="yellow"
        if [[ $(sysctl -n sysctl.proc_translated) = "1" ]]; then
          local="/usr/local"
        else
          local="/opt/homebrew"
        fi
        ;;
      *)
        error "unreachable"
        ;;
    esac
    export PATH="${HOME}/.local/bin:${local}/bin:/usr/bin:/bin:${HOME}/.local/sbin:${local}/sbin:/usr/sbin:/sbin"
    if [[ -d "${local}/opt/diffutils" ]]; then
      export PATH="/usr/local/opt/diffutils/bin:$PATH"
    fi
    if [[ -d "${local}/opt/kubectl@1.23" ]]; then
      export PATH="/usr/local/opt/kubectl@1.23/bin:$PATH"
    fi
    if [[ -d "${local}/opt/openssl@1.1" ]]; then
      export CPPFLAGS="-I${local}/opt/openssl@1.1/include"
      export LDFLAGS="-L/${local}/opt/openssl@1.1/lib"
      export OPENSSL_ROOT_DIR="${local}/opt/openssl@1.1"
    fi
    if [[ -d "${local}/opt/php@7.4" ]]; then
      export PATH="/usr/local/opt/php@7.4/bin:$PATH"
      export PATH="/usr/local/opt/php@7.4/sbin:$PATH"
    fi
    export SHELL="${local}/bin/bash"
    alias hide="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"
    alias show="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
    ;;
  *)
    local="/usr/local"
    export PATH="${HOME}/.local/bin:${local}/bin:/usr/bin:/bin:${HOME}/.local/sbin:${local}/sbin:/usr/sbin:/sbin"
    prompt_color="yellow"
    alias open="xdg-open"
    ;;
esac

# bash completion
[[ -r "${local}/etc/profile.d/bash_completion.sh" ]] && source "${local}/etc/profile.d/bash_completion.sh"

# basic
alias c=clear
alias ls="ls -al"

# rust
if [[ -d "$HOME/.cargo" ]]; then
  source "$HOME/.cargo/env"
  alias cb="cargo build"
  alias cc="cargo clippy --all-features --all"
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
is_in_path bat
if [[ "$?" -eq 0 ]]; then
  alias cat=bat
fi

# bazelisk
is_in_path bazelisk
if [[ "$?" -eq 0 ]]; then
  alias bazel=bazelisk
fi

# exa
is_in_path exa
if [[ "$?" -eq 0 ]]; then
  alias ls="exa -agl --color=always"
  alias tree="exa -aT --color=always --git-ignore"
fi

# deno
if [[ -d "$HOME/.deno" ]]; then
  export DENO_INSTALL="$HOME/.deno"
  export PATH="$PATH:$DENO_INSTALL/bin"
fi

# fzf
is_in_path fzf
if [[ "$?" -eq 0 ]]; then
  [[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
  export FZF_TMUX_OPTS="-p"
  export FZF_CTRL_R_OPTS="--reverse --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
fi

# git
is_in_path git
if [[ "$?" -eq 0 ]]; then
  alias gd="git diff -- :/ ':(exclude,top)*Cargo.lock'"
  alias gf="git log --follow --date=short --pretty=format:'%C(bold blue)%ad%C(reset) %C(bold yellow)%p %h%C(reset) %s %C(bold red)%an%C(reset)' -- ."
  alias gl="git log --decorate --graph --oneline"
fi

# go
if [[ -d "${local}/go/bin" ]]; then
  export PATH="$PATH:/usr/local/go/bin"
  export PATH="$PATH:$HOME/go/bin"
  is_in_path go1.16.7
  if [[ "$?" -eq 0 ]]; then
    export GOROOT=$(go1.16.7 env GOROOT)
    export PATH="$GOROOT/bin:$PATH"
  fi
fi

# gpg
is_in_path gpgconf
if [[ "$?" -eq 0 ]]; then
  unset SSH_AGENT_PID
  if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi
  export GPG_TTY=$(tty)
  gpg-connect-agent updatestartuptty /bye >/dev/null
fi

# jenv
if [[ -d "$HOME/.jenv" ]]; then
  export PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"
fi

# just
is_in_path just
if [[ "$?" -eq 0 ]]; then
  alias j=just
  source <(just --completions bash)
  complete -F _just -o bashdefault -o default j
fi

# k8s
is_in_path kubectl
if [[ "$?" -eq 0 ]]; then
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
  source <(kubectl completion bash)
fi

# nvim
is_in_path nvim
if [[ "$?" -eq 0 ]]; then
  export EDITOR=nvim
  export VISUAL=nvim
  alias nvim="nvim --startuptime /tmp/nvim-startuptime"
fi

# nvm
if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  [[ -s "${local}/opt/nvm/nvm.sh" ]] && source "${local}/opt/nvm/nvm.sh"
  [[ -s "${local}/opt/nvm/etc/bash_completion.d/nvm" ]] && source "${local}/opt/nvm/etc/bash_completion.d/nvm"
fi

# npm
npm_dir="${HOME}/.config/npm"
if [[ -d $npm_dir ]]; then
  export PATH="$PATH:$npm_dir/bin"
  export MANPATH="${MANPATH-$(manpath)}:$npm_dir/share/man"
fi

# pipenv
is_in_path pipenv
if [[ "$?" -eq 0 ]]; then
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
is_in_path rg
if [[ "$?" -eq 0 ]]; then
  alias grep=rg
fi

# solana
solana_dir="$HOME/.local/share/solana/install/active_release/bin"
if [[ -d $solana_dir ]]; then
  export PATH="$PATH:$solana_dir"
fi

# yarn
is_in_path yarn
if [[ "$?" -eq 0 ]]; then
  export PATH="$(yarn global bin):$PATH"
fi

# Other
set -o vi
[[ -r ~/.bash_secret ]] && source ~/.bash_secret
