{
  config,
  pkgs,
  ...
}:
{
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;

    settings = {
      env = {
        TERM = "xterm-256color";
      };

      window = {
        padding = {
          x = 15;
          y = 15;
        };
        dynamic_padding = true;
        decorations = "Full";
        startup_mode = "Windowed";
        opacity = 0.95;
        blur = false;
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        size = 16;
        offset = {
          x = 0;
          y = 1;
        };
      };

      cursor = {
        style = {
          shape = "Block";
          blinking = "Off";
        };
        unfocused_hollow = true;
      };

      selection.save_to_clipboard = true;

      mouse.bindings = [
        {
          mouse = "Right";
          action = "Paste";
        }
      ];
    };
  };
}
