{
  config,
  inputs,
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
      generateCompletions = true;
      package = unstablePkgs.fish;
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
