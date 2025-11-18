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
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = true;

      nvidiaSettings = true;
      modesetting.enable = true;

      dynamicBoost.enable = false;
      powerManagement.enable = false;
    };
  };
}
