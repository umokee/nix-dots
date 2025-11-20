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
  };
}
