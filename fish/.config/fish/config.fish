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
        echo red
    else
        echo blue
    end
end

function fish_prompt
    set -l out ($HOME/.local/bin/prompt --color (color))
    echo -e $out "\n\$ "
end

fish_vi_key_bindings

if test (uname -s) = Darwin
    fzf --fish | source

    # Force certain more-secure behaviours from homebrew
    set -x HOMEBREW_NO_INSECURE_REDIRECT 1
    set -x HOMEBREW_CASK_OPTS --require-sha
    set -x HOMEBREW_DIR /opt/homebrew
    set -x HOMEBREW_BIN /opt/homebrew/bin

    # Add GCloud to PATH
    source "/opt/homebrew/share/google-cloud-sdk/path.fish.inc"

    set -gx VOLTA_HOME "$HOME/.volta"
    set -gx PATH "$VOLTA_HOME/bin" $PATH
end

# Point GOPATH to our go sources
set -x GOPATH "$HOME/go"

# Add binaries that are go install-ed to PATH
set -U fish_user_paths $GOPATH/bin $fish_user_paths

direnv hook fish | source

pyenv init - fish | source

source ~/.config/fish/secret.fish
