{
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "acme";
in
{
  config = lib.mkIf enable {
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "hituaev@gmail.com";
      };
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts."umkcloud.ru" = {
        enableACME = true;

        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
            ssl = false;
          }
        ];

        locations."/" = {
          return = "301 https://github.com$request_uri";
        };
      };

      virtualHosts."umkcloud-ssl.ru" = {
        serverName = "umkcloud.ru";

        listen = [
          {
            addr = "127.0.0.1";
            port = 8444;
            ssl = true;
          }
        ];

        useACMEHost = "umkcloud.ru";

        locations."/" = {
          return = "301 https://github.com$request_uri";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 ];

    users.users.haproxy.extraGroups = [ "acme" ];
  };
}
