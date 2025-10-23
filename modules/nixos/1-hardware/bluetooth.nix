{
  config,
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "hardware" "bluetooth";
in
{
  config = lib.mkIf enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      package = pkgs.bluez;

      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      bluez-tools
    ];

    services.blueman.enable = true;
  };
}
