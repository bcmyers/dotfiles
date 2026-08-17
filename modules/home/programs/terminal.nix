{ config, ... }:
{
  fonts.fontconfig.enable = true;

  home.file.".local/bin/yank.sh" = {
    source = ../../../files/bin/yank.sh;
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
}
