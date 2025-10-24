{
  lib,
  pkgs,
  helpers,
  ...
}:
{
  config = lib.mkIf helpers.isWM {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;

      extraPortals =
        with pkgs;
        [
          xdg-desktop-portal-gtk
        ]
        ++ lib.optionals helpers.isWlr [
          xdg-desktop-portal-wlr
        ]
        ++ lib.optionals helpers.isHyprland [
          xdg-desktop-portal-hyprland
        ];

      config = {
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
          "org.freedesktop.impl.portal.Settings" = "gtk";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.Inhibit" = "gtk";
        };
        mangowc = {
          default = [
            "wlr"
            "gtk"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
          "org.freedesktop.impl.portal.Settings" = "gtk";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.Inhibit" = "gtk";
        };
        common = {
          default = [ "gtk" ];
        };
      };
    };

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
      };
    };
  };
}
