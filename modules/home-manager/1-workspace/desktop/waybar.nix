{
  config,
  helpers,
  lib,
  ...
}:
{
  programs.waybar = lib.mkIf (!helpers.isDwl) {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };

    settings = {
      mainBar = {
        output = [
          "eDP-1"
          "HDMI-A-5"
        ];
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;

        modules-left =
          [ ]
          ++ lib.optionals helpers.isHyprland [
            "hyprland/workspaces"
            "custom/sep"
            "hyprland/window"
            "custom/sep"
          ]
          ++ lib.optionals helpers.isMango [
            "ext/workspaces"
            "custom/sep"
            "dwl/window#layout"
            "custom/sep"
            "dwl/window#title"
          ];

        modules-center = [ ];

        modules-right =
          [ ]
          ++ lib.optionals helpers.isLaptop [
            "custom/sep"
            "battery"
          ]
          ++ [
            "custom/sep"
            "network"
            "custom/sep"
            "cpu"
            "custom/sep"
            "memory"
            "custom/sep"
            "disk"
            "custom/sep"
            "clock"
            "custom/sep"
            "tray"
          ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          warp-on-scroll = false;
          format = "{name}";
          persistent-workspaces = {
            "*" = 9;
          };
        };

        "hyprland/window" = {
          max-length = 40;
          separate-outputs = false;
        };

        "ext/workspaces" = {
          format = "{icon}";
          ignore-hidden = false;
          on-click = "activate";
          sort-by-id = true;
        };

        "dwl/tags" = {
          num-tags = 9;
        };

        "dwl/window#layout" = {
          format = "[{layout}]";
        };

        "dwl/window#title" = {
          format = "{title}";
        };

        tray = {
          spacing = 10;
        };

        clock = {
          format-alt = "{:%Y-%m-%d}";
        };

        cpu = {
          format = "CPU: {usage}%";
          tooltip = false;
        };

        memory = {
          format = "Mem: {used}GiB";
        };

        disk = {
          interval = 60;
          path = "/";
          format = "Disk: {free}";
        };

        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "Bat: {capacity}% {icon} {time}";
          format-plugged = "{capacity}% ";
          format-alt = "Bat {capacity}%";
          format-time = "{H}:{M}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        network = {
          format = "Online";
          format-disconnected = "Disconnected ⚠";
        };

        "custom/sep" = {
          format = "|";
          interval = "once";
          tooltip = false;
        };
      };
    };

    style =
      let
        palette = config.colorScheme.palette;
      in
      ''
        @define-color bg    #${palette.base00}; 
        @define-color fg    #${palette.base05}; 
        @define-color blk   #${palette.base01}; 
        @define-color red   #${palette.base08}; 
        @define-color grn   #${palette.base0B}; 
        @define-color ylw   #${palette.base0A}; 
        @define-color blu   #${palette.base0D}; 
        @define-color mag   #${palette.base0E}; 
        @define-color cyn   #${palette.base0C}; 
        @define-color brblk #${palette.base02}; 
        @define-color white #${palette.base06}; 

        * {
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 16px;
            font-weight: bold;
        }

        window#waybar {
            background-color: @bg;
            color: @fg;
        }

        #workspaces button {
            padding: 0 6px;
            color: @cyn;
            background: transparent;
            border-bottom: 3px solid @bg;
        }

        #workspaces button.active {
            color: @cyn;
            border-bottom: 3px solid @mag;
        }

        #workspaces button.empty {
            color: @white;
        }

        #workspaces button.empty.active {
            color: @cyn;
            border-bottom: 3px solid @mag;
        }

        #workspaces button.urgent {
            background-color: @red;
        }

        button:hover {
            background: inherit;
            box-shadow: inset 0 -3px #ffffff;
        }

        #clock,
        #custom-sep,
        #battery,
        #cpu,
        #memory,
        #disk,
        #network,
        #tray {
            padding: 0 8px;
            color: @white;
        }

        #custom-sep {
            color: @brblk;
        }

        #clock {
            color: @cyn;
            border-bottom: 4px solid @cyn;
        }

        #battery {
            color: @mag;
            border-bottom: 4px solid @mag;
        }

        #disk {
            color: @ylw;
            border-bottom: 4px solid @ylw;
        }

        #memory {
            color: @mag;
            border-bottom: 4px solid @mag;
        }

        #cpu {
            color: @grn;
            border-bottom: 4px solid @grn;
        }

        #network {
            color: @blu;
            border-bottom: 4px solid @blu;
        }

        #network.disconnected {
            background-color: @red;
        }

        #tray {
            background-color: @blu;
        }
      '';
  };
}
