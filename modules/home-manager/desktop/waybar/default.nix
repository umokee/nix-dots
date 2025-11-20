{
  config,
  helpers,
  lib,
  ...
}:
let
  modules = import ./modules.nix { };
  style = import ./style.nix { inherit config; };
in
{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };

    settings = {
      mainBar =
        {
          output = [
            "DP-3"
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
        }
        // modules;
    };

    inherit style;
  };
}
