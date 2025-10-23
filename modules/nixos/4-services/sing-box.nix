{
  config,
  pkgs,
  lib,
  conf,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "sing-box";
in
{
  config = lib.mkIf enable {
    services.sing-box = {
      enable = true;
      package = pkgs.sing-box;
      
      settings = {
        log = {
          level = "info";
          timestamp = true;
        };

        dns = {
          servers = [
            {
              tag = "cloudflare";
              address = "https://1.1.1.1/dns-query";
            }
            {
              tag = "google";
              address = "https://8.8.8.8/dns-query";
            }
          ];
          rules = [
            {
              geosite = "cn";
              server = "cloudflare";
            }
          ];
          strategy = "prefer_ipv4";
        };

        inbounds = [
          {
            type = "vless";
            tag = "vless-in";
            listen = "127.0.0.1";
            listen_port = 8443;
            
            users = [
              {
                uuid = "2bb6e04c-e434-4065-bfde-3e92a4e926c2";
                flow = "xtls-rprx-vision";
              }
              {
                uuid = "fd539ebe-41ea-4e8d-af6a-ae58a5636ab4";
                flow = "xtls-rprx-vision";
              }
            ];

            tls = {
              enabled = true;
              server_name = "www.github.com";
              reality = {
                enabled = true;
                handshake = {
                  server = "www.github.com";
                  server_port = 443;
                };
                private_key = "6DMV09BexNFlw1zf1My259gOc_Z1IsyYwNVCi1RWqFg";
                short_id = [ "1d0702eb71b9b044" ];
              };
            };

            transport = {
              type = "http";
            };
          }

          {
            type = "mixed";
            tag = "mixed-in";
            listen = "127.0.0.1";
            listen_port = 10808;
          }
        ];

        outbounds = [
          {
            type = "direct";
            tag = "direct";
          }
          {
            type = "block";
            tag = "block";
          }
        ];

        route = {
          rules = [
            {
              inbound = [ "vless-in" "mixed-in" ];
              outbound = "direct";
            }
          ];
        };
      };
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 443 80 ];
    };

    systemd.services.sing-box.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "sing-box";
      Group = "sing-box";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/sing-box" ];
    };

    users.users.sing-box = {
      isSystemUser = true;
      group = "sing-box";
      home = "/var/lib/sing-box";
      createHome = true;
    };
    users.groups.sing-box = {};
  };
}
