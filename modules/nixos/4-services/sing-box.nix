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
          type = "udp";
          tag = "dns-proxy";
          server = "1.1.1.1";
          detour = "proxy";
        }
        {
          type = "udp";
          tag = "dns-direct";
          server = "8.8.8.8";
        }
        {
          type = "local";
          tag = "dns-local";
        }
      ];
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
          domain_regex = [
            "^(.+\\.)?twitch\\.tv$"
            "^(.+\\.)?ttvnw\\.net$"
            "^(.+\\.)?twitchcdn\\.net$"
            "^(.+\\.)?jtvnw\\.net$"
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
        strict_route = false;
        sniff = true;
        sniff_override_destination = true;
        stack = "gvisor";
        # endpoint_independent_nat = true;
      }
      {
        type = "socks";
        tag = "socks";
        listen = "127.0.0.1";
        listen_port = 9050;
        sniff = true;
        sniff_override_destination = true;
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

            #"/nix/store/[^/]*/bin/python3.13"
            #"/nix/store/[^/]*/bin/bwrap"
          ];
          outbound = "proxy";
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

  singboxWrapper = pkgs.stdenv.mkDerivation {
    name = "singbox-wrapper";
    version = "1.0";

    src = pkgs.writeText "wrapper.c" ''
      #include <unistd.h>
      #include <signal.h>
      #include <sys/wait.h>
      #include <stdlib.h>

      int main() {
          pid_t pid = fork();
          if (pid == 0) {
              char *args[] = {"${pkgs.sing-box}/bin/sing-box", "run", "-c", "/etc/sing-box-config.json", NULL};
              execv(args[0], args);
              return 1;
          } else if (pid > 0) {
              int status;
              waitpid(pid, &status, 0);
              return WIFEXITED(status) ? WEXITSTATUS(status) : 1;
          } else {
              return 1;
          }
      }
    '';

    nativeBuildInputs = [
      pkgs.gcc
      pkgs.patchelf
    ];

    unpackPhase = "true";

    buildPhase = ''
      gcc $src -o singbox-wrapper
    '';

    installPhase = ''
      mkdir -p $out/bin
      install -m755 singbox-wrapper $out/bin/
    '';
  };
in
{
  config = lib.mkIf enable {
    environment.systemPackages = [ pkgs.sing-box ];
    networking.firewall.trustedInterfaces = [ "nekoray-tun" ];

    environment.etc."sing-box-config.json".text = builtins.toJSON singboxSettings;

    systemd.services.singbox-wrapper = {
      description = "Singbox Wrapper Service";
      wantedBy = [ ]; # "multi-user.target"
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${singboxWrapper}/bin/singbox-wrapper";
        Restart = "on-failure";
        RestartSec = 5;
        StandardOutput = "journal";
        StandardError = "journal";
        KillSignal = "SIGTERM";
        TimeoutStopSec = "20s";
      };
    };
  };
}
