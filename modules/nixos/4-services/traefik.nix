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
        };

        log = {
          level = "INFO";
        };

        accessLog = { };
      };

      dynamicConfigOptions = {
        http = {
          routers = {
            domain-https = {
              rule = "Host(`umkcloud.ru`) || Host(`www.umkcloud.ru`)";
              entryPoints = [ "websecure" ];
              service = "github-redirect";
              middlewares = [ "redirect-github" ];
              tls = {
                certResolver = "letsencrypt";
              };
              priority = 100;
            };
          };

          services = {
            github-redirect = {
              loadBalancer = {
                servers = [
                  { url = "http://127.0.0.1:1"; }
                ];
              };
            };
          };

          middlewares = {
            redirect-github = {
              redirectRegex = {
                regex = ".*";
                replacement = "https://github.com";
                permanent = true;
              };
            };
          };
        };

        tcp = {
          routers = {
            vless-tcp = {
              rule = "HostSNI(`github.com`) || HostSNI(`www.github.com`)";
              entryPoints = [ "websecure" ];
              service = "xray-service";
              tls = {
                passthrough = true;
              };
              priority = 50;
            };

            fallback-tcp = {
              rule = "HostSNI(`*`)";
              entryPoints = [ "websecure" ];
              service = "github-service";
              tls = {
                passthrough = true;
              };
              priority = 1;
            };
          };

          services = {
            xray-service = {
              loadBalancer = {
                servers = [
                  { address = "127.0.0.1:8443"; }
                ];
              };
            };

            github-service = {
              loadBalancer = {
                servers = [
                  { address = "github.com:443"; }
                ];
              };
            };
          };
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/traefik 0750 traefik traefik -"
      "f /var/lib/traefik/acme.json 0600 traefik traefik -"
    ];

    users.users.traefik = {
      isSystemUser = true;
      group = "traefik";
    };
    users.groups.traefik = { };
  };
}
