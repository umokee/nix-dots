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
          level = "DEBUG";
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
      # HTTP роутеры (обрабатываются ПЕРВЫМИ для SSL termination)
      http:
        routers:
          # Роутер для домена с SSL
          domain-https:
            rule: "Host(`umkcloud.ru`) || Host(`www.umkcloud.ru`)"
            entryPoints:
              - websecure
            service: github-redirect
            middlewares:
              - redirect-github
            tls:
              certResolver: letsencrypt
            priority: 100  # Высокий приоритет!
          
          # Редирект HTTP -> HTTPS
          domain-http:
            rule: "Host(`umkcloud.ru`) || Host(`www.umkcloud.ru`)"
            entryPoints:
              - web
            service: github-redirect
            middlewares:
              - redirect-https
            priority: 100
        
        services:
          # Dummy service для редиректа
          github-redirect:
            loadBalancer:
              servers:
                - url: "http://127.0.0.1:1"
        
        middlewares:
          # Редирект на HTTPS
          redirect-https:
            redirectScheme:
              scheme: https
              permanent: true
          
          # Редирект на GitHub
          redirect-github:
            redirectRegex:
              regex: "^https?://.*"
              replacement: "https://github.com"
              permanent: true
      
      # TCP роутеры (обрабатываются ПОСЛЕ HTTP)
      tcp:
        routers:
          # VLESS роутер (github.com SNI)
          vless-tcp:
            rule: "HostSNI(`github.com`, `www.github.com`)"
            entryPoints:
              - websecure
            service: xray-service
            tls:
              passthrough: true
            priority: 50
          
          # Fallback роутер (все остальные SNI)
          fallback-tcp:
            rule: "HostSNI(`*`)"
            entryPoints:
              - websecure
            service: github-service
            tls:
              passthrough: true
            priority: 1  # Самый низкий приоритет
        
        services:
          # Xray сервис
          xray-service:
            loadBalancer:
              servers:
                - address: "127.0.0.1:8443"
          
          # GitHub fallback сервис
          github-service:
            loadBalancer:
              servers:
                - address: "github.com:443"
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
