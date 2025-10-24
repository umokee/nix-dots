{ ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  services.dbus = {
    enable = true;
    implementation = "broker";
  };

  programs.dconf.enable = true;
  # programs.xfconf.enable = true;
  system.stateVersion = "25.05";
}
