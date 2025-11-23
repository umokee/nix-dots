{
  pkgs,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "sing-box";

  rule_sets = {
    antizapret = pkgs.fetchurl {
      url = "https://github.com/savely-krasovsky/antizapret-sing-box/releases/latest/download/antizapret.srs";
      sha256 = "sha256-rU9fW8VM+/hUrniQg9BBw7ZFMD+sY49GF4XTBdtnd64=";
    };
    refilter_domains = pkgs.fetchurl {
      url = "https://github.com/1andrevich/Re-filter-lists/releases/latest/download/ruleset-domain-refilter_domains.srs";
      sha256 = "sha256-wZJpqcz225XxFnXKs1kUAF+9UdcaDWQZWua5CQ4fSTw=";
    };
    refilter_ipsum = pkgs.fetchurl {
      url = "https://github.com/1andrevich/Re-filter-lists/releases/latest/download/ruleset-ip-refilter_ipsum.srs";
      sha256 = "sha256-Rt34UdnrYU5/kVak7PsNRq3BBY+A+DEPJtoFrrQI8Os=";
    };
    geoip-ru = pkgs.fetchurl {
      url = "https://cdn.jsdelivr.net/gh/SagerNet/sing-geoip@rule-set/geoip-ru.srs";
      sha256 = "sha256-pCwbEX/ltxaLTFgM26E6j1N4ANgl7isazbhTScewkw8=";
    };
  };

  singboxSettings = {
    log = {
      level = "warn";
      output = "box.log";
      timestamp = true;
    };
    experimental = {
      cache_file = {
        enabled = true;
        path = "cache.db";
      };
    };
    dns = {
      servers = [
        {
          type = "https";
          tag = "dns-proxy";
          server = "1.1.1.1";
          server_port = 443;
          path = "/dns-query";
          detour = "proxy";
        }
        {
          type = "https";
          tag = "dns-direct";
          server = "8.8.8.8";
          server_port = 443;
          path = "/dns-query";
        }
        {
          type = "local";
          tag = "dns-local";
          detour = "direct";
        }
      ];
      disable_cache = false;
      disable_expire = false;
      independent_cache = true;
      #strategy = "ipv4_only";
      final = "dns-direct";
      reverse_mapping = true;
      rules = [
        {
          query_type = [
            32
            33
          ];
          action = "reject";
        }
        {
          domain_suffix = ".lan";
          action = "reject";
        }
        {
          domain_suffix = [
            ".nixos.org"
            ".cachix.org"
          ];
          action = "route";
          server = "dns-direct";
        }
        {
          domain_regex = [
            "^(.+\\.)?twitch\\.tv$"
            "^(.+\\.)?ttvnw\\.net$"
            "^(.+\\.)?twitchcdn\\.net$"
            "^(.+\\.)?jtvnw\\.net$"

            "^(.+\\.)?sheets\\.google\\.com$"
            "^(.+\\.)?docs\\.google\\.com$"
            "^(.+\\.)?drive\\.google\\.com$"
            "^(.+\\.)?accounts\\.google\\.com$"
            "^(.+\\.)?apis\\.google\\.com$"
            "^(.+\\.)?googleapis\\.com$"
            "^(.+\\.)?googleusercontent\\.com$"
            "^(.+\\.)?gstatic\\.com$"
            "^(.+\\.)?vercel\\.com$"
            "^(.+\\.)?v0\\.app$"
          ];
          action = "route";
          server = "dns-proxy";
        }
        {
          rule_set = [
            "antizapret"
            "refilter_domains"
          ];
          action = "route";
          server = "dns-proxy";
        }
      ];
    };
    inbounds = [
      {
        type = "tun";
        tag = "tun-in";
        interface_name = "nekoray-tun";
        address = [ "172.19.0.1/28" ];
        mtu = 1500;
        auto_route = true;
        strict_route = true;
        sniff = true;
        stack = "system";
      }
      {
        type = "socks";
        tag = "socks";
        listen = "127.0.0.1";
        listen_port = 9050;
        sniff = true;
      }
    ];
    outbounds = [
      {
        type = "vless";
        tag = "proxy";
        server = "185.223.169.86";
        server_port = 443;
        uuid = "2bb6e04c-e434-4065-bfde-3e92a4e926c2";
        flow = "xtls-rprx-vision";
        tls = {
          enabled = true;
          server_name = "github.com";
          reality = {
            enabled = true;
            public_key = "naGPegUP-BSqpa5Nxw4q8-4vvGrvc1gOlZmc_c6VChA";
            short_id = "1d0702eb71b9b044";
          };
          utls = {
            enabled = true;
            fingerprint = "chrome";
          };
        };
      }
      {
        type = "direct";
        tag = "direct";
      }
    ];
    route = {
      default_domain_resolver = {
        server = "dns-direct";
      };
      auto_detect_interface = true;
      final = "direct";
      rules = [
        {
          protocol = "dns";
          action = "hijack-dns";
        }
        {
          process_path_regex = [
            "/nix/store/[^/]*/share/mullvad-browser/mullvadbrowser"
            "/nix/store/[^/]*/rider/bin/.rider-wrapped"
            "/nix/store/[^/]*/rider/bin/fsnotifier"
            "/nix/store/[^/]*/rider/lib/ReSharperHost/linux-x64/Rider.Backend"
          ];
          outbound = "proxy";
        }
        {
          domain_suffix = [
            ".nixos.org"
            ".cachix.org"
            "cache.nixos.org"
            "nix-community.cachix.org"
          ];
          outbound = "direct";
        }
        {
          ip_is_private = true;
          outbound = "direct";
        }
        {
          ip_cidr = [
            "224.0.0.0/3"
            "ff00::/8"
          ];
          action = "reject";
        }
        {
          source_ip_cidr = [
            "224.0.0.0/3"
            "ff00::/8"
          ];
          action = "reject";
        }
        {
          network = "udp";
          port = [
            21
            23
            135
            137
            138
            139
            445
            3306
            3389
            5353
          ];
          action = "reject";
        }
        {
          inbound = [ "socks" ];
          outbound = "proxy";
        }
        {
          rule_set = [ "geoip-ru" ];
          outbound = "direct";
        }
        {
          domain_regex = [
            "^(.+\\.)?twitch\\.tv$"
            "^(.+\\.)?ttvnw\\.net$"
            "^(.+\\.)?twitchcdn\\.net$"
            "^(.+\\.)?jtvnw\\.net$"

            "^(.+\\.)?sheets\\.google\\.com$"
            "^(.+\\.)?forms\\.google\\.com$"
            "^(.+\\.)?docs\\.google\\.com$"
            "^(.+\\.)?drive\\.google\\.com$"
            "^(.+\\.)?accounts\\.google\\.com$"
            "^(.+\\.)?apis\\.google\\.com$"
            "^(.+\\.)?googleapis\\.com$"
            "^(.+\\.)?googleusercontent\\.com$"
            "^(.+\\.)?gstatic\\.com$"
            "^(.+\\.)?gnusenpai\\.net$"
            "^(.+\\.)?typingstudy\\.com$"
            "^(.+\\.)?typingclub\\.com$"
            "^(.+\\.)?typing\\.com$"
            "^(.+\\.)?penpot\\.app$"
            "^(.+\\.)?diagrams\\.net$"
            "^(.+\\.)?draw\\.io$"
            "^(.+\\.)?creately\\.com$"
            "^(.+\\.)?yworks\\.com$"
            "^(.+\\.)?whimsical\\.com$"
          ];
          outbound = "proxy";
        }
        {
          rule_set = [
            "antizapret"
            "refilter_domains"
            "refilter_ipsum"
          ];
          outbound = "proxy";
        }
      ];
      rule_set = [
        {
          tag = "antizapret";
          type = "local";
          format = "binary";
          path = "${rule_sets.antizapret}";
        }
        {
          tag = "refilter_domains";
          type = "local";
          format = "binary";
          path = "${rule_sets.refilter_domains}";
        }
        {
          tag = "refilter_ipsum";
          type = "local";
          format = "binary";
          path = "${rule_sets.refilter_ipsum}";
        }
        {
          tag = "geoip-ru";
          type = "local";
          format = "binary";
          path = "${rule_sets.geoip-ru}";
        }
      ];
    };
  };
in
{
  config = lib.mkIf enable {
    environment.etc."sing-box-config.json".text = builtins.toJSON singboxSettings;
  };
}
