#!/usr/bin/env bash

[[ $- != *i* ]] && return

# basic
alias c=clear
alias gd="git diff HEAD"
alias gdt="git difftool HEAD"
alias ls="ls -al"
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PAGER=less
export SHELL=/bin/bash

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

# go
if command -v go &>/dev/null; then
	export GOBIN=$HOME/go/bin
	export GOPATH=$HOME/go
	[[ :$PATH: != *:$GOBIN:* ]] && PATH=$GOBIN:$PATH
fi

# ~/bin
[[ -d $HOME/.cargo ]] && [[ :$PATH: != *:$HOME/.cargo/bin:* ]] && PATH=$HOME/.cargo/bin:$PATH
[[ -d $HOME/bin ]] && [[ :$PATH: != *:$HOME/bin:* ]] && PATH=$HOME/bin:$PATH

# os
case "$(uname -s)" in
    Linux*)     os=linux;;
    Darwin*)    os=macos;;
    CYGWIN*)    os=cygwin;;
    MINGW*)     os=mingw;;
    *)          os="UNKNOWN:$(uname -s)"
esac

if [[ $os == "macos" ]]; then
	alias hide="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"
	alias show="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
	[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
    export SHELL=/usr/local/bin/bash
fi


# prompt
prompt_command() {
	local exit="$?"
	if command -v prompt &>/dev/null; then
		if [[ $exit == "0" ]]; then
			PS1="$(prompt --color="bright blue")\n$ "
		else
			PS1="$(prompt --color="bright red")\n$ "
		fi
	else
		PS1="$exit \u@\H \w\n$ "
	fi
}

PROMPT_COMMAND=prompt_command

# gpg
if command -v gpgconf &>/dev/null; then
    GPT_TTY=$(tty)
    export GPG_TTY
    SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    export SSH_AUTH_SOCK
    gpgconf --launch gpg-agent
fi

# kubectl
if command -v kubectl &>/dev/null; then
    alias k=kubectl
fi

# nvim
if command -v nvim &>/dev/null; then
	alias nano=nvim
	alias vi=nvim
	alias vim=nvim
	export EDITOR=nvim
	export VISUAL=nvim
elif command -v vim &>/dev/null; then
	export EDITOR=vim
	export VISUAL=vim
else
	export EDITOR=vi
	export VISUAL=vi
fi

# nvm
if [[ -d $HOME/.nvm ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
    [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
fi

if command -v npm &>/dev/null; then
    NPM_PACKAGES="${HOME}/.config/npm" # TODO: Make this directory if it doesn't exist
    PATH="$PATH:$NPM_PACKAGES/bin"
    export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"
fi

# pipenv
# command -v pipenv &>/dev/null && eval "$(pipenv --completion)"

# pyenv
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
    source $(pyenv root)/completions/pyenv.bash
    mkdir -p $(pyenv root)/cache
fi
if which pyenv-virtualenv-init > /dev/null; then
    eval "$(pyenv virtualenv-init -)";
fi

# vi mode
set -o vi

command -v bat &>/dev/null && alias cat=bat
command -v dust &>/dev/null && alias du=dust
command -v exa &>/dev/null && alias ls="exa -agl" && alias tree="exa -T --git-ignore"
command -v fd &>/dev/null && alias find=fd
command -v git &>/dev/null && alias gl="git log --decorate --graph --oneline"
command -v rg &>/dev/null && alias grep=rg

# rust
if command -v rustc &>/dev/null; then
	RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/src
    # TODO: CARGO_BUILD_JOBS
	export RUST_SRC_PATH
fi

# vault
if command -v vault &>/dev/null; then
    complete -C "$HOME/bin/vault" vault
    export VAULT_ADDR='http://127.0.0.1:8200'
fi

export PATH

# other
[[ -f ~/.bash_other ]] && source ~/.bash_other

export PATH="/usr/local/opt/binutils/bin:$PATH"

export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
