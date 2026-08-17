{
  config,
  inputs,
  isDarwin,
  lib,
  pkgs,
  unstablePkgs,
  ...
}:
let
  prompt = unstablePkgs.callPackage ../packages/prompt.nix {
    src = inputs.prompt-src;
  };
in
{
  fonts.fontconfig.enable = true;

  home.file.".local/bin/yank.sh" = {
    source = ../scripts/.local/bin/yank.sh;
    executable = true;
  };

  programs = {
    alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        font = {
          size = 14.0;
          normal = {
            family = "Inconsolata Nerd Font Mono";
            style = "Regular";
          };
          bold = {
            family = "Inconsolata Nerd Font Mono";
            style = "Bold";
          };
          italic = {
            family = "Inconsolata Nerd Font Mono";
            style = "Italic";
          };
          bold_italic = {
            family = "Inconsolata Nerd Font Mono";
            style = "Bold Italic";
          };
        };
        general.live_config_reload = true;
        window = {
          opacity = 1.0;
          padding = {
            x = 5;
            y = 5;
          };
        };
      };
    };

    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [
        "erasedups"
        "ignoredups"
        "ignorespace"
      ];
      historyFile = "${config.xdg.stateHome}/bash/history";
    };

    bat.enable = true;

    awscli = {
      enable = true;
      package = pkgs.awscli2;
      settings."profile brian.myers".region = "us-east-1";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    eza = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      git = true;
      icons = "auto";
    };

    fish = {
      enable = true;
      # Home Manager 26.05 expects a generator removed by newer Fish releases.
      # Packages' native Fish completions remain available.
      generateCompletions = false;
      package = unstablePkgs.fish;
      shellInit = ''
        # Retire path entries persisted by the legacy, imperative Fish config.
        # Home Manager's sessionPath and nix-darwin now own PATH instead.
        set --erase --universal fish_user_paths
        set --erase --global fish_user_paths

        # GUI terminals can retain a pre-activation PATH until the next login.
        # Make the pinned fzf visible before its Fish integration initializes.
        set --prepend --global --export PATH ${lib.getBin unstablePkgs.fzf}/bin
      ''
      + lib.optionalString isDarwin ''
        # Keep Homebrew as a deduplicated, lowest-priority macOS fallback even
        # when Terminal inherited the old Homebrew-first environment.
        set -l path_without_homebrew
        for path_entry in $PATH
          if not contains -- $path_entry /opt/homebrew/bin /opt/homebrew/sbin
            if not contains -- $path_entry $path_without_homebrew
              set --append path_without_homebrew $path_entry
            end
          end
        end
        set --global --export PATH $path_without_homebrew /opt/homebrew/bin /opt/homebrew/sbin
      '';
      functions.fish_prompt = ''
        set -l prompt_output (${lib.getExe prompt})
        echo -e "$prompt_output\n\$ "
      '';
      shellAbbrs = {
        c = "clear";
        cc = "cargo clippy";
        ls = "eza -al";
      };
      interactiveShellInit = ''
        set -g fish_greeting
        fish_vi_key_bindings
      '';
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      package = unstablePkgs.fzf;
    };

    git = {
      enable = true;
      package = pkgs.gitFull;
      signing = {
        format = "openpgp";
        key = "B86678B99457460F";
        signByDefault = true;
      };
      settings = {
        core = {
          editor = "nvim";
          fsmonitor = true;
          untrackedCache = true;
        };
        diff.algorithm = "patience";
        fetch.prune = true;
        init.defaultBranch = "main";
        merge = {
          conflictStyle = "zdiff3";
          tool = "nvimdiff";
        };
        pull.rebase = true;
        push = {
          autoSetupRemote = true;
          default = "simple";
        };
        rebase.autoStash = true;
        user = {
          email = "brian.carl.myers@gmail.com";
          name = "Brian Myers";
        };
      };
    };

    gpg = {
      enable = true;
      package = unstablePkgs.gnupg;
      settings = {
        display-charset = "utf-8";
        keyid-format = "long";
        no-comments = true;
        no-emit-version = true;
        no-greeting = true;
        trust-model = "tofu+pgp";
        utf8-strings = true;
        with-fingerprint = true;
        with-keygrip = true;
      };
    };

    less.enable = true;

    man.generateCaches = pkgs.stdenv.hostPlatform.isLinux;

    neovim = {
      enable = true;
      defaultEditor = true;
      initLua = builtins.readFile ../nvim/.config/nvim/init.lua;
      package = unstablePkgs.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
    };

    password-store = {
      enable = true;
      package = unstablePkgs.pass.withExtensions (extensions: [ extensions.pass-otp ]);
    };

    readline = {
      enable = true;
      variables = {
        bell-style = "none";
        colored-stats = true;
        completion-ignore-case = true;
        editing-mode = "vi";
        show-all-if-ambiguous = true;
        show-mode-in-prompt = true;
      };
    };

    tmux = {
      enable = true;
      aggressiveResize = true;
      clock24 = true;
      escapeTime = 0;
      historyLimit = 50000;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      terminal = "tmux-256color";
      extraConfig = ''
        set-option -sa terminal-features ',xterm-256color:RGB'
        set -g focus-events on
        set -g renumber-windows on
        set -g set-clipboard on

        bind \\ split-window -h
        bind - split-window -v
        bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded"

        bind -n C-h if-shell -F '#{m/r:(n?vim|fzf),#{pane_current_command}}' 'send-keys C-h' 'select-pane -L'
        bind -n C-j if-shell -F '#{m/r:(n?vim|fzf),#{pane_current_command}}' 'send-keys C-j' 'select-pane -D'
        bind -n C-k if-shell -F '#{m/r:(n?vim|fzf),#{pane_current_command}}' 'send-keys C-k' 'select-pane -U'
        bind -n C-l if-shell -F '#{m/r:(n?vim|fzf),#{pane_current_command}}' 'send-keys C-l' 'select-pane -R'

        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel '${config.home.homeDirectory}/.local/bin/yank.sh'

        bind Right resize-pane -R 5
        bind Left resize-pane -L 5
        bind Up resize-pane -U 2
        bind Down resize-pane -D 2
      '';
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 7200;
    defaultCacheTtlSsh = 7200;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableSshSupport = true;
    maxCacheTtl = 7200;
    maxCacheTtlSsh = 7200;
    pinentry.package =
      if pkgs.stdenv.hostPlatform.isDarwin then unstablePkgs.pinentry_mac else pkgs.pinentry-curses;
  };

  xdg.configFile = {
    "nvim/after".source = ../nvim/.config/nvim/after;
    "nvim/nvim-pack-lock.json".source = ../nvim/.config/nvim/nvim-pack-lock.json;
  };
}
