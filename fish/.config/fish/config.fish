set -g fish_greeting ""

if test (uname -s) = Darwin
  set -U fish_user_paths /opt/homebrew/bin $fish_user_paths
end

set -U fish_user_paths $HOME/.local/bin $fish_user_paths

abbr c clear
abbr cat bat
abbr grep rg
abbr cc "cargo clippy --all"
abbr gf "git log --decorate=short --date=short --graph --pretty=format:'%C(bold blue)%ad%C(reset) %C(bold yellow)%h%C(reset) %<(5)%al %<(20)%s' --max-count=100"
abbr gl "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
abbr ls "eza -agl --color=always"

if test (uname -s) = Darwin
  abbr hide "defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"
  abbr show "defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
end

set -x EDITOR nvim
set -x PAGER "less -r --use-color"
set -x VISUAL nvim

function color
  if test (uname -s) = Linux
    echo "red"
  else
    echo "blue"
  end
end

function fish_prompt
  set -l out ($HOME/.local/bin/prompt --color (color))
  echo -e $out "\n\$ "
end

fish_vi_key_bindings

# Add datadog devtools binaries to the PATH
set -U fish_user_paths $HOME/dd/devtools/bin $fish_user_paths

# Point GOPATH to our go sources
set -x GOPATH "$HOME/go"

# Add binaries that are go install-ed to PATH
set -U fish_user_paths $GOPATH/bin $fish_user_paths

# Point DATADOG_ROOT to ~/dd symlink
set -x DATADOG_ROOT "$HOME/dd"

# Tell the devenv vm to mount $GOPATH/src rather than just dd-go
set -x MOUNT_ALL_GO_SRC 1

# store key in the login keychain instead of aws-vault managing a hidden keychain
set -x AWS_VAULT_KEYCHAIN_NAME login

# Helm switch from storing objects in kubernetes configmaps to
# secrets by default, but we still use the old default.
set -x HELM_DRIVER configmap

# Go 1.16+ sets GO111MODULE to off by default with the intention to
# remove it in Go 1.18, which breaks projects using the dep tool.
# https://blog.golang.org/go116-module-changes
set -x GO111MODULE auto
set -x GOPRIVATE github.com/DataDog
# Configure Go to pull go.ddbuild.io packages.
set -x GOPROXY binaries.ddbuild.io,https://proxy.golang.org,direct
set -x GONOSUMDB github.com/DataDog,go.ddbuild.io

if test (uname -s) = Darwin
  fzf --fish | source

  # Force certain more-secure behaviours from homebrew
  set -x HOMEBREW_NO_INSECURE_REDIRECT 1
  set -x HOMEBREW_CASK_OPTS --require-sha
  set -x HOMEBREW_DIR /opt/homebrew
  set -x HOMEBREW_BIN /opt/homebrew/bin

  # Prefer GNU binaries to Macintosh binaries.
  set -U fish_user_paths /opt/homebrew/opt/coreutils/libexec/gnubin $fish_user_paths

  # Add GCloud to PATH
  source "/opt/homebrew/share/google-cloud-sdk/path.fish.inc"

  set -x GITLAB_TOKEN (security find-generic-password -a $USER -s gitlab_token -w)

  set -gx VOLTA_HOME "$HOME/.volta"
  set -gx PATH "$VOLTA_HOME/bin" $PATH
end
