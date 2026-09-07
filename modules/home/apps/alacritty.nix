{ unstablePkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = [ unstablePkgs.nerd-fonts.inconsolata ];

  programs.alacritty = {
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
      terminal.osc52 = "OnlyCopy";
      window = {
        opacity = 1.0;
        padding = {
          x = 5;
          y = 5;
        };
      };
    };
  };
}
