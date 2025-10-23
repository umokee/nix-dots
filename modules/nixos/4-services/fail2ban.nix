{
  lib,
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
      maxretry = 3;

      bantime = "365d";
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
      };

      findtime = "24h";
      
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
