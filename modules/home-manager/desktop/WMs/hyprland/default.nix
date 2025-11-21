{
  lib,
  helpers,
  pkgs,
  ...
}:
let
  enable = helpers.hasIn "workspace" "hyprland";
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

        monitor = [
          "DP-3,2560x1440@165,0x0,1"
          "DP-4,1920x1080@100,2560x0,1,transform,3"
          "HDMI-A-5,1920x1080@60,510x1440,1.5"
        ];

        xwayland = {
          force_zero_scaling = false;
        };

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
          "10, monitor:DP-4, default:true"
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
          rounding_power = 0;

          active_opacity = 1.0;
          inactive_opacity = 1.0;

          blur = {
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

          bezier = [
            "specialWorkSwitch, 0.05, 0.7, 0.1, 1"
            "emphasizedAccel, 0.3, 0, 0.8, 0.15"
            "emphasizedDecel, 0.05, 0.7, 0.1, 1"
            "standard, 0.2, 0, 0, 1"
          ];

          animation = [
            "layersIn, 1, 5, emphasizedDecel, slide"
            "layersOut, 1, 4, emphasizedAccel, slide"
            "fadeLayers, 1, 5, standard"
            "windowsIn, 1, 5, emphasizedDecel"
            "windowsOut, 1, 3, emphasizedAccel"
            "windowsMove, 1, 6, standard"
            "workspaces, 1, 5, standard"
            "specialWorkspace, 1, 4, specialWorkSwitch, slidefadevert 15%"
            "fade, 1, 6, standard"
            "fadeDim, 1, 6, standard"
            "border, 1, 6, standard"
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
          #session_lock_xray = true;

          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
        };

        #gestures = {
        #  #workspace_swipe = true;
        #  workspace_swipe_distance = 700;
        #  #workspace_swipe_fingers = 4;
        #  workspace_swipe_cancel_ratio = 0.15;
        #  workspace_swipe_min_speed_to_force = 5;
        #  workspace_swipe_direction_lock = true;
        #  workspace_swipe_direction_lock_threshold = 10;
        #  workspace_swipe_create_new = true;
        #};

        binds = {
          scroll_event_delay = 0;
        };

        bind = [
          "Super, A, exec, ${pkgs.tofi}/bin/tofi-drun --drun-launch=true"
          "Super, Return, exec, foot"
          "Super, W, exec, zen"
          "Super, E, exec, nemo"
          "Super+Shift, S, exec, screenshot-tool clip"
          "Super, Q, killactive,"
          "Super, V, togglefloating"
          "Super, F, fullscreen,"
          "Super, h, movefocus, l"
          "Super, l, movefocus, r"
          "Super, k, movefocus, u"
          "Super, j, movefocus, d"
          "Super+Shift, h, movewindow, l"
          "Super+Shift, l, movewindow, r"
          "Super+Shift, k, movewindow, u"
          "Super+Shift, j, movewindow, d"
          "Super, 1, workspace, 1"
          "Super, 2, workspace, 2"
          "Super, 3, workspace, 3"
          "Super, 4, workspace, 4"
          "Super, 5, workspace, 5"
          "Super, 6, workspace, 6"
          "Super, 7, workspace, 7"
          "Super, 8, workspace, 8"
          "Super, 9, workspace, 9"
          "Super, 0, workspace, 10"
          "Super+Shift, 1, movetoworkspace, 1"
          "Super+Shift, 2, movetoworkspace, 2"
          "Super+Shift, 3, movetoworkspace, 3"
          "Super+Shift, 4, movetoworkspace, 4"
          "Super+Shift, 5, movetoworkspace, 5"
          "Super+Shift, 6, movetoworkspace, 6"
          "Super+Shift, 7, movetoworkspace, 7"
          "Super+Shift, 8, movetoworkspace, 8"
          "Super+Shift, 9, movetoworkspace, 9"
          "Super+Shift, 0, movetoworkspace, 10"
        ];

        bindm = [
          "Super, mouse:272, movewindow"
          "Super, mouse:273, resizewindow"
        ];

        bindel = [
          ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%"
        ];

        windowrule = [
          "opacity 0.95 override, fullscreen:0"
          "opaque, class:foot|equibop|org\.quickshell|imv|swappy"
          "center 1, floating:1, xwayland:0"
          "float, class:guifetch"
          "float, class:yad"
          "float, class:zenity"
          "float, class:wev"
          "float, class:org\.gnome\.FileRoller"
          "float, class:file-roller"
          "float, class:blueman-manager"
          "float, class:com\.github\.GradienceTeam\.Gradience"
          "float, class:feh"
          "float, class:imv"
          "float, class:system-config-printer"
          "float, class:org\.quickshell"
          "float, class:foot, title:nmtui"
          "size 60% 70%, class:foot, title:nmtui"
          "center 1, class:foot, title:nmtui"
          "float, class:org\.gnome\.Settings"
          "size 70% 80%, class:org\.gnome\.Settings"
          "center 1, class:org\.gnome\.Settings"
          "float, class:org\.pulseaudio\.pavucontrol|yad-icon-browser"
          "size 60% 70%, class:org\.pulseaudio\.pavucontrol|yad-icon-browser"
          "center 1, class:org\.pulseaudio\.pavucontrol|yad-icon-browser"
          "float, class:nwg-look"
          "size 50% 60%, class:nwg-look"
          "center 1, class:nwg-look"
          "float, title:(Select|Open)( a)? (File|Folder)(s)?"
          "float, title:File (Operation|Upload)( Progress)?"
          "float, title:.* Properties"
          "float, title:Export Image as PNG"
          "float, title:GIMP Crash Debug"
          "float, title:Save As"
          "float, title:Library"
          "move 100%-w-2% 100%-w-3%, title:Picture(-| )in(-| )[Pp]icture"
          "keepaspectratio, title:Picture(-| )in(-| )[Pp]icture"
          "float, title:Picture(-| )in(-| )[Pp]icture"
          "pin, title:Picture(-| )in(-| )[Pp]icture"
          "rounding 10, title:, class:steam"
          "float, title:Friends List, class:steam"
          "immediate, class:steam_app_[0-9]+"
          "idleinhibit always, class:steam_app_[0-9]+"
          "float, class:com-atlauncher-App, title:ATLauncher Console"
          "noblur, title:Fusion360|(Marking Menu), class:fusion360\.exe"
          "nodim, xwayland:1, title:win[0-9]+"
          "noshadow, xwayland:1, title:win[0-9]+"
          "rounding 10, xwayland:1, title:win[0-9]+"
        ];

        windowrulev2 = [
          "noinitialfocus, class:^(.*jetbrains.*)$, title:^(win.*)$"
        ];
      };
    };
  };
}
