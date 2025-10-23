{
  config,
  lib,
  pkgs,
  conf,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "podman";
in
{
  config = lib.mkIf enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    
    users.users.${conf.username}.extraGroups = [ "podman" ];

    environment.systemPackages = with pkgs; [
      podman
      podman-compose
    ];
  };
}
