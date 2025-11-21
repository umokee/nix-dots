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
      bantime = "52w";

      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "10000d";
        rndtime = "600";
      };

      jails = {
        sshd.settings = {
          enabled = true;
          filter = "sshd";
          port = "ssh";
          mode = "aggressive";
          findtime = "3600";
        };

        recidive = {
          settings = {
            enabled = true;
            filter = "recidive";
            logpath = "/var/log/fail2ban.log";
            action = "iptables-allports[name=recidive]";
            findtime = "86400";
            maxretry = 3;
          };
        };
      };
    };
  };
}
