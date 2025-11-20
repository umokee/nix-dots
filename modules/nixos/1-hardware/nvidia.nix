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
    boot.kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = false;

      nvidiaSettings = true;
      modesetting.enable = true;

      powerManagement.enable = false;
      powerManagement.finegrained = false;

      nvidiaPersistenced = false;
    };
  };
}
