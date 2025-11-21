{
  helpers,
  ...
}:
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = if helpers.isDesktop then "DP-3" else "eDP-1";
        origin = "bottom-center";
        offset = "(0, 20)";
        width = "(300, 500)";
        height = 300;

        transparency = 10;
        padding = 12;
        horizontal_padding = 12;
        text_icon_padding = 16;

        frame_width = 2;
        corner_radius = 0;
        gap_size = 6;

        font = "JetBrainsMono Nerd Font 13";
        format = "<b>%s</b>\\n%b";
        markup = "full";
        alignment = "left";
        vertical_alignment = "center";

        icon_position = "left";
        min_icon_size = 48;
        max_icon_size = 64;
        icon_theme = "Papirus_Dark";
        enable_recursive_icon_lookup = true;

        sticky_history = true;
        history_length = 50;
        show_indicators = true;
        show_age_threshold = 60;
        stack_duplicates = true;
        hide_duplicate_count = false;
        notification_limit = 5;

        progress_bar = true;
        progress_bar_height = 14;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        progress_bar_corner_radius = 5;

        sort = true;
        idle_threshold = 120;
        word_wrap = true;
        ignore_newline = false;

        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";

        layer = "overlay";
        force_xwayland = false;

        browser = "/usr/bin/xdg-open";
        dmenu = "rofi -dmenu";
      };

      urgency_low = {
        timeout = 3;
      };

      urgency_normal = {
        timeout = 6;
      };

      urgency_critical = {
        timeout = 0;
      };
    };
  };
}
