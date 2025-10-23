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
        forceSSL = false;
        
        locations."/" = {
          return = "301 https://github.com$request_uri";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 ];

    users.users.haproxy.extraGroups = [ "acme" ];
  };
}
