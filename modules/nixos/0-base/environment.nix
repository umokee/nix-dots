{
  config,
  lib,
  conf,
  helpers,
  pkgs,
  ...
}:
{
  config = {
    environment.sessionVariables = lib.mkMerge [
      (lib.mkIf helpers.isWayland {
        NIXOS_OZONE_WL = "1";
        XDG_SESSION_TYPE = "wayland";
        QT_QPA_PLATFORM = "wayland;xcb";
        GDK_BACKEND = "wayland,x11";
        _JAVA_AWT_WM_NONREPARENTING = "1";
        SDL_VIDEODRIVER = "wayland,x11";
        CLUTTER_BACKEND = "wayland";
      })

      (lib.mkIf helpers.isDwl {
        XDG_CURRENT_DESKTOP = "dwl";
        XDG_SESSION_DESKTOP = "dwl";
      })

      (lib.mkIf helpers.isHyprland {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
      })

      (lib.mkIf helpers.hasNvidia {
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
      })

      (lib.mkIf (!helpers.hasNvidia && helpers.hasIntel) {
        LIBVA_DRIVER_NAME = "iHD";
      })

      (lib.mkIf (!helpers.hasNvidia && helpers.hasAMD) {
        LIBVA_DRIVER_NAME = "radeonsi";
      })
    ];
  };
}
