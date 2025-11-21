{
  config,
  lib,
  helpers,
  pkgs,
  ...
}:
let
  enable = helpers.hasIn "hardware" "nvidia";
in
{
  config = lib.mkIf enable {
    # Critical kernel parameters for NVIDIA + Wayland
    boot.kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      # НОВОЕ: Отключить GSP firmware (может вызывать артефакты)
      "nvidia.NVreg_EnableGpuFirmware=0"
      # НОВОЕ: Force full composition pipeline
      "nvidia.NVreg_RegistryDwords=PowerMizerEnable=0x1;PerfLevelSrc=0x2222"
    ];

    services.xserver.videoDrivers = [ "nvidia" ];

    # ВАЖНО: Добавить дополнительные опции для Xorg (влияет на Wayland тоже)
    services.xserver.screenSection = ''
      Option         "Coolbits" "28"
      Option         "TripleBuffer" "on"
      Option         "metamodes" "nvidia-auto-select +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
    '';

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      # ПОПРОБУЕМ ВЕРНУТЬ OPEN (может быть в вашем случае лучше)
      open = lib.mkDefault false;

      nvidiaSettings = true;
      modesetting.enable = true;

      powerManagement.enable = true;
      powerManagement.finegrained = false;

      nvidiaPersistenced = true;

      # НОВОЕ: Force full composition pipeline через driver
      forceFullCompositionPipeline = true;

      dynamicBoost.enable = false;
    };

    # Дополнительные сервисы для стабильности
    systemd.services.nvidia-persistenced = {
      description = "NVIDIA Persistence Daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "forking";
        ExecStart = "${config.hardware.nvidia.package}/bin/nvidia-persistenced --user nvidia-persistenced --persistence-mode";
      };
    };

    users.users.nvidia-persistenced = {
      isSystemUser = true;
      group = "nvidia-persistenced";
    };
    users.groups.nvidia-persistenced = {};

    # NVIDIA environment variables
    environment.sessionVariables = {
      # Базовые NVIDIA настройки
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";

      # VRR/G-Sync - ОТКЛЮЧАЕМ для тестирования
      __GL_GSYNC_ALLOWED = "0";
      __GL_VRR_ALLOWED = "0";

      # КРИТИЧНО: Отключить hardware cursors
      WLR_NO_HARDWARE_CURSORS = "1";

      # NVIDIA + Wayland оптимизации (МАКСИМАЛЬНО АГРЕССИВНЫЕ)
      __GL_THREADED_OPTIMIZATION = "0";
      __GL_SHADER_DISK_CACHE = "0"; # Полностью отключить shader cache
      __GL_SYNC_TO_VBLANK = "0"; # Отключить vsync на уровне драйвера
      __GL_YIELD = "USLEEP"; # Лучше для wlroots

      # VRAM preservation
      NVIDIA_PRESERVE_VIDEO_MEMORY_ALLOCATIONS = "1";
      __GL_MaxFramesAllowed = "1"; # Отключить triple buffering

      # Для wlroots: ПОПРОБУЕМ PIXMAN вместо Vulkan
      WLR_RENDERER = "pixman"; # Software renderer - МОЖЕТ ПОМОЧЬ!
      WLR_DRM_NO_ATOMIC = "1";

      # Electron/Chromium приложения
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      # НОВОЕ: Дополнительные NVIDIA специфичные переменные
      __GL_ALLOW_UNOFFICIAL_PROTOCOL = "1";
      __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
    };
  };
}
