{
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "xray";
in
{
  config = lib.mkIf enable {
    services.xray = {
      enable = true;

      settings = {
        log = {
          loglevel = "warning";
        };
        routing = {
          rules = [
            {
              ip = [ "geoip:private" ];
              outboundTag = "BLOCK";
              type = "field";
            }
            {
              protocol = "bittorrent";
              outboundTag = "BLOCK";
              type = "field";
            }
            {
              domain = [
                "geosite:category-gov-ru"
                "regexp:.*\\.ru$"
                "regexp:.*\\.рф$"
                "regexp:.*\\.su$"
              ];
              outboundTag = "BLOCK";
              type = "field";
            }
            {
              ip = [ "geoip:ru" ];
              outboundTag = "BLOCK";
              type = "field";
            }
          ];
        };
        inbounds = [
          {
            tag = "vless-in";
            listen = "127.0.0.1";
            port = 8443;
            protocol = "vless";

            settings = {
              clients = [
                {
                  id = "2bb6e04c-e434-4065-bfde-3e92a4e926c2";
                  flow = "xtls-rprx-vision";
                }
                {
                  id = "fd539ebe-41ea-4e8d-af6a-ae58a5636ab4";
                  flow = "xtls-rprx-vision";
                }
              ];
              decryption = "none";
            };
            streamSettings = {
              network = "tcp";
              security = "reality";
              realitySettings = {
                show = false;
                dest = "github.com:443";
                xver = 0;
                serverNames = [
                  "github.com"
                  "www.github.com"
                ];
                privateKey = "6DMV09BexNFlw1zf1My259gOc_Z1IsyYwNVCi1RWqFg";
                shortIds = [
                  "1d0702eb71b9b044"
                ];
              };
            };
            sniffing = {
              enabled = true;
              destOverride = [
                "http"
                "tls"
                "quic"
              ];
            };
          }
        ];
        outbounds = [
          {
            protocol = "freedom";
            tag = "DIRECT";
          }
          {
            protocol = "blackhole";
            tag = "BLOCK";
          }
        ];
      };
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        443
        80
      ];
    };
  };
}
