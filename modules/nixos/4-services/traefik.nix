{
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "traefik";
in
{
  config = lib.mkIf enable {
    services.traefik = {
      enable = true;
      
      staticConfigOptions = {
        entryPoints = {
          web = {
            address = ":80";
            http = {
              redirections = {
                entryPoint = {
                  to = "websecure";
                  scheme = "https";
                };
              };
            };
          };
          
          websecure = {
            address = ":443";
          };
        };
        
        certificatesResolvers = {
          letsencrypt = {
            acme = {
              email = "hituaev@gmail.com";
              storage = "/var/lib/traefik/acme.json";
              httpChallenge = {
                entryPoint = "web";
              };
            };
          };
        };
        
        api = {
          dashboard = true;
          insecure = false;
        };
        
        log = {
          level = "INFO";
        };
        
        accessLog = {};
        
        providers = {
          file = {
            filename = "/etc/traefik/dynamic.yml";
            watch = true;
          };
        };
      };
    };

    environment.etc."traefik/dynamic.yml".text = ''
      tcp:
        routers:
          # VLESS роутер (github.com SNI)
          vless-router:
            rule: "HostSNI(`github.com`) || HostSNI(`www.github.com`)"
            entryPoints:
              - websecure
            service: xray-service
            tls:
              passthrough: true
          
          fallback-router:
            rule: "HostSNI(`*`)"
            entryPoints:
              - websecure
            service: github-service
            priority: 1
            tls:
              passthrough: true
        
        services:
          xray-service:
            loadBalancer:
              servers:
                - address: "127.0.0.1:8443"
          
          github-service:
            loadBalancer:
              servers:
                - address: "github.com:443"
      
      http:
        routers:
          domain-router:
            rule: "Host(`umkcloud.ru`) || Host(`www.umkcloud.ru`)"
            entryPoints:
              - websecure
            service: redirect-service
            middlewares:
              - github-redirect
            tls:
              certResolver: letsencrypt
        
        services:
          redirect-service:
            loadBalancer:
              servers:
                - url: "http://127.0.0.1:1"
        
        middlewares:
          github-redirect:
            redirectRegex:
              regex: "^https://.*"
              replacement: "https://github.com"
              permanent: true
    '';

    systemd.tmpfiles.rules = [
      "d /var/lib/traefik 0750 traefik traefik -"
      "f /var/lib/traefik/acme.json 0600 traefik traefik -"
    ];

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    users.users.traefik = {
      isSystemUser = true;
      group = "traefik";
    };
    users.groups.traefik = {};
  };
}
