{
  config,
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "fail2ban";
in
{
  config = lib.mkIf enable {
    services.fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "1024h";
      
      jails = {
        sshd.settings = {
          enabled = true;
          filter = "sshd";
          port = "ssh";
          mode = "aggresive";
        };
      };
    };
  };
}
