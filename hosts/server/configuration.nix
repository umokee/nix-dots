{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  services.dbus = {
    enable = true;
    #implementation = "broker";
  };

  networking.useDHCP = lib.mkDefault true;
  system.stateVersion = "25.05";
}
