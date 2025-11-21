{
  lib,
  helpers,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf helpers.isWayland {
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XDG_SESSION_TYPE = "wayland";

        QT_QPA_PLATFORMTHEME = "qt5ct";
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_FORCE_DPI = "140";
      };
    })

    (lib.mkIf helpers.isHyprland {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

      environment.sessionVariables = {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
      };
    })
  ];
}
