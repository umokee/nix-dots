{
  config,
  lib,
  conf,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "base" "network";
in
{
  config = lib.mkIf enable {
    networking = {
      hostName = conf.hostname;
      networkmanager.enable = true;

      firewall = {
        enable = lib.mkDefault false;
        allowPing = true;
      };
    };
  };
}
