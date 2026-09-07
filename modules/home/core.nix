{ config, ... }:
{
  home = {
    preferXdgDirectories = true;

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
    ];

    sessionVariables = {
      EDITOR = "nvim";
      LESS = "-FRX";
      PAGER = "less";
      VISUAL = "nvim";
    };

    shellAliases = {
      cat = "bat";
      grep = "rg";
    };
  };

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };
}
