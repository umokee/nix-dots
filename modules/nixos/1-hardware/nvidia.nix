{
  config,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "hardware" "nvidia";
in
{
  config = lib.mkIf enable {
    # Enable nvidia-drm modeset for better Wayland support
    boot.kernelParams = [ "nvidia-drm.modeset=1" ];

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = true;

      nvidiaSettings = true;
      modesetting.enable = true;

      # Enable power management to reduce flickering issues
      powerManagement.enable = true;
      powerManagement.finegrained = false;

      dynamicBoost.enable = false;
    };
  };
}
