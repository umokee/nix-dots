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
          vless-router:
            rule: "HostSNI(`github.com`) || HostSNI(`www.github.com`)"
            entryPoints:
              - websecure
            service: xray-service
            tls:
              passthrough: true
          
          domain-router:
            rule: "HostSNI(`umkcloud.ru`) || HostSNI(`www.umkcloud.ru`)"
            entryPoints:
              - websecure
            service: redirect-service
            tls:
              certResolver: letsencrypt
          
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
          
          redirect-service:
            loadBalancer:
              servers:
                - address: "127.0.0.1:8080"
          
          github-service:
            loadBalancer:
              servers:
                - address: "github.com:443"
      
      http:
        routers:
          redirect-router:
            rule: "Host(`umkcloud.ru`) || Host(`www.umkcloud.ru`)"
            entryPoints:
              - websecure
            service: redirect-http
            tls:
              certResolver: letsencrypt
        
        services:
          redirect-http:
            loadBalancer:
              servers:
                - url: "http://127.0.0.1:8080"
        
        middlewares:
          github-redirect:
            redirectRegex:
              regex: "^https://umkcloud\\.ru(.*)"
              replacement: "https://github.com$1"
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
