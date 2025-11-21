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
    boot.kernelParams = [
      "nvidia-drm.modeset=1"
    ];

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = true;

      nvidiaSettings = true;
      modesetting.enable = true;

      powerManagement.enable = false;
      powerManagement.finegrained = false;

      nvidiaPersistenced = false;
    };

    environment.sessionVariables = {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";

      WLR_NO_HARDWARE_CURSORS = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };
}
