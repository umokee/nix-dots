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

        apache-auth = {
          settings = {
            enabled = false;
            filter = "apache-auth";
            logpath = "/var/log/httpd/*error.log";
            maxretry = 3;
            bantime = "7d";
          };
        };

        nginx-http-auth = {
          settings = {
            enabled = false;
            filter = "nginx-http-auth";
            logpath = "/var/log/nginx/error.log";
            maxretry = 3;
            bantime = "7d";
          };
        };

        nginx-4xx = {
          settings = {
            enabled = false;
            filter = "nginx-4xx";
            logpath = "/var/log/nginx/access.log";
            maxretry = 10;
            bantime = "1h";
            findtime = "300";
          };
        };

        nginx-botsearch = {
          settings = {
            enabled = false;
            filter = "nginx-botsearch";
            logpath = "/var/log/nginx/access.log";
            maxretry = 5;
            bantime = "24h";
          };
        };
      };
    };
  };
}
