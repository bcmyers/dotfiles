{ ... }:
{
  programs.tmux = {
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
      set -s set-clipboard external

      bind \\ split-window -h
      bind - split-window -v
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded"

      bind -n C-h if-shell -F '#{m/r:(n?vim|fzf),#{pane_current_command}}' 'send-keys C-h' 'select-pane -L'
      bind -n C-j if-shell -F '#{m/r:(n?vim|fzf),#{pane_current_command}}' 'send-keys C-j' 'select-pane -D'
      bind -n C-k if-shell -F '#{m/r:(n?vim|fzf),#{pane_current_command}}' 'send-keys C-k' 'select-pane -U'
      bind -n C-l if-shell -F '#{m/r:(n?vim|fzf),#{pane_current_command}}' 'send-keys C-l' 'select-pane -R'

      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind Right resize-pane -R 5
      bind Left resize-pane -L 5
      bind Up resize-pane -U 2
      bind Down resize-pane -D 2
    '';
  };
}
