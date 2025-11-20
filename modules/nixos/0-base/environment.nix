{
  lib,
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

      (lib.mkIf helpers.isMango {
        XDG_CURRENT_DESKTOP = "wlroots";
        XDG_SESSION_DESKTOP = "wlroots";
      })

      (lib.mkIf helpers.isHyprland {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
      })

      (lib.mkIf helpers.hasNvidia {
        # Базовые NVIDIA настройки
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";

        # Enable VRR/G-Sync to prevent flickering on supported monitors
        __GL_GSYNC_ALLOWED = "1";
        __GL_VRR_ALLOWED = "1";

        # КРИТИЧНО: Отключить hardware cursors для wlroots/mangowc
        # Это ОСНОВНАЯ причина черных артефактов на NVIDIA + Wayland!
        WLR_NO_HARDWARE_CURSORS = "1";

        # NVIDIA + Wayland оптимизации (против артефактов)
        __GL_THREADED_OPTIMIZATION = "0";  # Отключить, может вызывать артефакты
        __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";  # Не чистить shader cache
        NVIDIA_PRESERVE_VIDEO_MEMORY_ALLOCATIONS = "1";  # Сохранять VRAM

        # Для wlroots композиторов (mangowc)
        WLR_RENDERER = "vulkan";  # Использовать Vulkan вместо OpenGL
        WLR_DRM_NO_ATOMIC = "1";  # Отключить atomic modesetting (может помочь)

        # Electron/Chromium приложения
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      })

      (lib.mkIf (!helpers.hasNvidia && helpers.hasIntel) {
        LIBVA_DRIVER_NAME = "iHD";
      })
    ];
  };
}
