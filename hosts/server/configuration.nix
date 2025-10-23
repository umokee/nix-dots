{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.useDHCP = lib.mkDefault true;
  system.stateVersion = "25.05";
}
