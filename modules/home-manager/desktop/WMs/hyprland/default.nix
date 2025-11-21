{
  lib,
  helpers,
  pkgs,
  ...
}:
let
  enable = helpers.hasIn "workspace" "hyprland";

  keybinds = import ./keybinds.nix { inherit pkgs; };
  rules = import ./rules.nix;
in
{
  config = lib.mkIf enable {
    programs.bash.profileExtra = lib.mkIf helpers.isWM ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec uwsm start hyprland-uwsm.desktop
      fi
    '';

    wayland.windowManager.hyprland = {
      enable = true;

      settings = {
        exec-once = [
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "echo 'Xft.dpi: 125' | xrdb -merge"
          "gsettings set org.gnome.desktop.interface text-scaling-factor 1.25"
        ];

        monitor = [ ",1920x1080@60, auto, 1" ];
        xwayland.force_zero_scaling = false;

        workspace = [
          "1, monitor:DP-3, default:true"
          "2, monitor:DP-3"
          "3, monitor:DP-3"
          "4, monitor:DP-3"
          "5, monitor:DP-3"
          "6, monitor:HDMI-A-5, default:true"
          "7, monitor:HDMI-A-5"
          "8, monitor:HDMI-A-5"
          "9, monitor:HDMI-A-5"
          "10, monitor:HDMI-A-5"
          "11, monitor:DP-4, default:true"
        ];

        input = {
          kb_layout = "us,ru-custom";
          kb_options = "grp:ctrl_shift_toggle";
          repeat_rate = 50;
          repeat_delay = 300;

          follow_mouse = 1;
          focus_on_close = 1;
          sensitivity = 0;

          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            scroll_factor = 0.3;
          };
        };

        general = {
          gaps_in = 2;
          gaps_out = 2;
          border_size = 1;
          resize_on_border = false;
          allow_tearing = false;
          layout = "dwindle";
        };

        decoration = {
          rounding = 0;
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          blur = lib.mkIf helpers.isDesktop {
            enabled = false;
            xray = false;
            special = false;
            ignore_opacity = true;
            new_optimizations = true;
            popups = true;
            input_methods = true;
            size = 8;
            passes = 2;
          };

          shadow = {
            enabled = false;
          };
        };

        animations = {
          enabled = false;
          bezier = "specialWorkSwitch,0.05,0.7,0.1,1";
          animation = [
            "layersIn,1,5,emphasizedDecel,slide"
            "layersOut,1,4,emphasizedAccel,slide"
            "windowsIn,1,5,emphasizedDecel"
            "windowsOut,1,3,emphasizedAccel"
            "workspaces,1,5,standard"
          ];
        };

        dwindle = {
          preserve_split = true;
          smart_split = false;
          smart_resizing = true;
        };

        misc = {
          vfr = true;
          vrr = 1;
          animate_manual_resizes = false;
          animate_mouse_windowdragging = false;
          disable_hyprland_logo = true;
          force_default_wallpaper = 0;
          new_window_takes_over_fullscreen = 2;
          allow_session_lock_restore = true;
          middle_click_paste = false;
          focus_on_activate = true;
          session_lock_xray = true;

          mouse_move_enables_dpms = lib.mkIf helpers.isLaptop true;
          keypress_enables_dpms = lib.mkIf helpers.isLaptop true;

          gestures = lib.mkIf helpers.isLaptop {
            workspace_swipe = false;
            workspace_swipe_fingers = 0;
            workspace_swipe_distance = 0;
            workspace_swipe_cancel_ratio = 0;
            workspace_swipe_min_speed_to_force = 0;
            workspace_swipe_create_new = false;
          };
        };
      };

      inherit keybinds rules;
    };
  };
}
