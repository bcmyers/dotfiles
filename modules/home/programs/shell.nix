{
  config,
  lib,
  pkgs,
  promptPackage,
  unstablePkgs,
  ...
}:
{
  programs = {
    man.generateCaches = pkgs.stdenv.hostPlatform.isLinux;

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
        # GUI terminals can retain a pre-activation PATH until the next login.
        # Make the pinned fzf visible before its Fish integration initializes.
        set --prepend --global --export PATH ${lib.getBin unstablePkgs.fzf}/bin
      '';
      functions.fish_prompt = ''
        set -l prompt_output (${lib.getExe promptPackage})
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

    less.enable = true;

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
  };
}
