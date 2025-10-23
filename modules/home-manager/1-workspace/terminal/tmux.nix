{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;

    terminal = "tmux-256color";
    prefix = "C-a";
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    sensibleOnTop = true;

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_status_style "rounded"
          
          set -g status-right-length 100
          set -g status-left-length 100
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_application}"
          set -agF status-right "#{E:@catppuccin_status_cpu}"
          set -ag status-right "#{E:@catppuccin_status_session}"
          set -ag status-right "#{E:@catppuccin_status_uptime}"
          set -agF status-right "#{E:@catppuccin_status_battery}"
        '';
      }
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
      tmuxPlugins.sessionist
    ];

    extraConfig = ''
      bind s choose-tree -sZ -O name

      unbind %
      bind | split-window -v
      unbind '"'
      bind - split-window -h

      unbind r
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reload

      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5
      bind -r m resize-pane -Z

      bind-key -T copy-mode-vi 'v' send -X begin-selection 
      bind-key -T copy-mode-vi 'y' send -X copy-selection 
      unbind -T copy-mode-vi MouseDragEnd1Pane
    '';
  };
}
