{
  description = "Home Manager flake";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/77f1c7636a92973be913ec21be5203edba017100";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/22.05";
  };

  outputs = { self, home-manager, nixpkgs }:
    let
      username = "bcmyers";
    in {
      nixpkgs.config.allowUnfree = true;
      homeConfigurations = {
        "${username}@macbook-intel" =
          let
            system = "x86_64-darwin";
          in
            home-manager.lib.homeManagerConfiguration {
              inherit system;
              inherit username;
              configuration = { pkgs, ... }: {

                home.packages = with pkgs; [
                  autoconf automake awscli bash bash-completion
                  bazel-buildtools bazelisk bzip2 clang-tools coreutils curl
                  diffoscope diffutils fzf gettext gitAndTools.gitFull gnuplot
                  gnused htop hyperfine jq libtool moreutils neovim newsboat
                  ninja nmap pandoc patchutils pinentry pulumi-bin qemu
                  qrencode rs-git-fsmonitor salt shellcheck shfmt stow
                  sumneko-lua-language-server terraform-ls tree-sitter tmux
                  tree vault xz wget yarn yq
                ];

                home.file.".config/alacritty/alacritty.yml".text = ''
                  env:
                    TERM: xterm-256color

                  font:
                    normal:
                      family: Inconsolata Nerd Font Mono
                      style: Regular
                    bold:
                      family: Inconsolata Nerd Font Mono
                      style: Bold
                    italic:
                      family: Inconsolata Nerd Font Mono
                      style: Italic
                    bold_italic:
                      family: Inconsolata Nerd Font Mono
                      style: Bold Italic
                    size: 14.0

                  live_config_reload: true

                  save_to_clipboard: true

                  window:
                    opacity: 0.95

                    dimensions:
                      columns: 400
                      lines: 100

                    position:
                      x: 0
                      y: 0

                    padding:
                      x: 5
                      y: 5
                '';

                home.file.".hushlogin".text = "";

                home.file.".inputrc".text = ''
                  # Ignore case for autocomplete
                  set completion-ignore-case on

                  # Show all possibilities for autocomplete
                  set show-all-if-ambiguous on

                  # Allow UTF-8 input and output, instead of showing stuff like $'\0123\0456'
                  set input-meta on
                  set output-meta on
                  set convert-meta off

                  # colorized completion
                  set colored-stats on

                  # turn off bell
                  set bell-style none

                  # vi mode
                  set editing-mode vi
                  set show-mode-in-prompt on
                  # set vi-ins-mode-string "(i)"
                  # set vi-cmd-mode-string "(c)"
                  $if term=linux
                    set vi-ins-mode-string \1\e[?0c\2
                    set vi-cmd-mode-string \1\e[?8c\2
                  $else
                    set vi-ins-mode-string \1\e[6 q\2
                    set vi-cmd-mode-string \1\e[2 q\2
                  $endif
                '';

                home.file.".tmux.conf".text = ''
                  unbind C-b
                  set -g prefix C-a
                  bind C-a send-prefix

                  set -s escape-time 0
                  set -g history-limit 50000
                  set -g display-time 4000
                  set -g focus-events on
                  setw -g aggressive-resize on

                  bind \\ split-window -h
                  bind - split-window -v
                  bind c new-window
                  bind n next-window
                  bind p previous-window
                  bind r source-file ~/.tmux.conf \; display-message "Config reloaded..."

                  # https://thoughtbot.com/blog/seamlessly-navigate-vim-and-tmux-splits
                  bind -n C-h run "(tmux display-message -p '#{pane_current_command}' | grep -iq vim && tmux send-keys C-h) || tmux select-pane -L"
                  bind -n C-j run "(tmux display-message -p '#{pane_current_command}' | grep -iq vim && tmux send-keys C-j) || tmux select-pane -D"
                  bind -n C-k run "(tmux display-message -p '#{pane_current_command}' | grep -iq vim && tmux send-keys C-k) || tmux select-pane -U"
                  bind -n C-l run "(tmux display-message -p '#{pane_current_command}' | grep -iq vim && tmux send-keys C-l) || tmux select-pane -R"

                  set-window-option -g mode-keys vi

                  bind -T copy-mode-vi v send-keys -X begin-selection

                  # Remap keys which perform copy to pipe copied text to OS clipboard
                  yank="~/.local/bin/yank.sh"
                  bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "$yank"
                  # old --> bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'reattach-to-user-namespace pbcopy'

                  set -s default-terminal screen-256color
                  set-option -a terminal-overrides ",*256col*:RGB"

                  set -g renumber-windows on

                  set -g mouse on
                  setw -g alternate-screen on

                  set -g status-interval 1
                  set-option -g status-position bottom
                  set -g status-left "#[fg=black,bold] #(whoami)@#h | #(KUBE_TMUX_SYMBOL_USE_IMG=false /bin/bash $HOME/opt/kube-tmux/kube.tmux black black black) | #S | "
                  set -g status-left-length 200
                  set -g status-right "#[fg=black,bold]%A %d %B %Y %H:%M:%S %Z "
                  set -g status-right-length 150

                  set -g status-bg blue
                  set -g pane-active-border-style "bg=default fg=blue"
                  set -g status-fg black
                  set -g pane-border-style fg=black

                  bind Right resize-pane -R 5
                  bind Left resize-pane -L 5
                  bind Up resize-pane -U 2
                  bind Down resize-pane -D 2
                '';

                programs.home-manager.enable = true;

                programs.git = {
                  enable = true;
                  package = pkgs.gitAndTools.gitFull;
                  signing = {
                    key = "B86678B99457460F";
                    signByDefault = true;
                  };
                  userEmail = "brian.myers@robinhood.com";
                  userName ="Brian Myers";
                  extraConfig = {
                    alias = {};
                    core = {
                      editor = "${pkgs.neovim}/bin/nvim";
                      fsmonitor = "${pkgs.rs-git-fsmonitor}/bin/rs-git-fsmonitor";
                      untrackedcache = true;
                    };
                    diff = {
                      algorithm = "patience";
                    };
                    init = {
                      defaultBranch = "main";
                    };
                    merge = {
                      conflictstyle = "diff3";
                      tool = "${pkgs.neovim}/bin/nvim -d";
                    };
                    pull = {
                      ff = "only";
                      rebase = true;
                    };
                    push = {
                      default = "simple";
                    };
                  };
                };

                nixpkgs.config.allowUnfree = true;
              };

              homeDirectory = "/Users/${username}";
              pkgs = builtins.getAttr system nixpkgs.outputs.legacyPackages;
              stateVersion = "22.05";
            };
      };
    };
}
