{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  services.dbus = {
    enable = true;
    implementation = "broker";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/gto5eMkM9Ghp5VScGT58ebz1VHCMhCpj8Hse4OjKI"
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
  ];

  networking.useDHCP = lib.mkDefault true;
  system.stateVersion = "25.05";
}
