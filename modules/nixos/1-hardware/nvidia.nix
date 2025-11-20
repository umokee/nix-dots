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
      "nvidia-drm.fbdev=1"  # Enable framebuffer, fixes artifacts
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"  # Fix suspend/resume artifacts
    ];

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # ВАЖНО: Попробуйте проприетарные драйвера вместо open
      # Open source драйвера могут иметь проблемы с артефактами
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = false;  # Изменено: false = проприетарные драйвера

      nvidiaSettings = true;
      modesetting.enable = true;

      # Enable power management to reduce flickering issues
      powerManagement.enable = true;
      powerManagement.finegrained = false;

      # Preserve video memory on suspend/resume (критично для артефактов!)
      nvidiaPersistenced = true;

      dynamicBoost.enable = false;
    };

    # Дополнительные сервисы для стабильности
    systemd.services.nvidia-persistenced = {
      description = "NVIDIA Persistence Daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "forking";
        ExecStart = "${pkgs.linuxPackages.nvidia_x11}/bin/nvidia-persistenced --user nvidia-persistenced --persistence-mode";
      };
    };

    # Создать пользователя для nvidia-persistenced
    users.users.nvidia-persistenced = {
      isSystemUser = true;
      group = "nvidia-persistenced";
    };
    users.groups.nvidia-persistenced = {};
  };
}
