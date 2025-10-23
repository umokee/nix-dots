{
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "hardware" "sound";
in
{
  config = lib.mkIf enable {
    boot.kernelParams = [ "usbcore.autosuspend=-1" ];
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      jack.enable = true;
      pulse.enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 256;
          "default.clock.min-quantum" = 256;
          "default.clock.max-quantum" = 256;
        };
      };

      wireplumber.extraConfig = {
        "10-disable-camera" = {
          "wireplumber.profiles" = {
            main = {
              "monitor.libcamera" = "disabled";
            };
          };
        };
      };
    };
  };
}
