{
  pkgs,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "sing-box";

  singboxSettings = {
    dns = {
      servers = [
        {
          tag = "dns-remote";
          address = "8.8.8.8";
          detour = "proxy";
        }
        {
          tag = "dns-direct";
          address = "1.1.1.1";
          detour = "direct";
        }
        {
          tag = "dns-local";
          address = "local";
          detour = "direct";
        }
      ];
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
          server = "dns-remote";
        }
        {
          rule_set = "refilter_domains";
          server = "dns-remote";
        }
        {
          rule_set = "refilter_ipsum";
          server = "dns-remote";
        }
      ];
      final = "dns-direct";
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
        endpoint_independent_nat = true;
      }
      {
        type = "socks";
        tag = "socks";
        listen = "127.0.0.1";
        listen_port = 9050;
        sniff = true;
      }
    ];
    log = {
      level = "info";
    };
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
      rule_set = [
        {
          tag = "refilter_domains";
          type = "remote";
          format = "binary";
          url = "https://github.com/1andrevich/Re-filter-lists/releases/latest/download/ruleset-domain-refilter_domains.srs";
          download_detour = "proxy";
        }
        {
          tag = "refilter_ipsum";
          type = "remote";
          format = "binary";
          url = "https://github.com/1andrevich/Re-filter-lists/releases/latest/download/ruleset-ip-refilter_ipsum.srs";
          download_detour = "proxy";
        }
      ];
      auto_detect_interface = true;
      final = "direct";
      rules = [
        {
          protocol = "dns";
          action = "hijack-dns";
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
          inbound = [ "socks" ];
          outbound = "proxy";
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
          rule_set = "refilter_domains";
          outbound = "proxy";
        }
        {
          rule_set = "refilter_ipsum";
          outbound = "proxy";
        }
      ];
    };
    experimental = {
      cache_file = {
        enabled = true;
      };
    };
  };

  singboxWrapper =
    pkgs.runCommand "singbox-wrapper"
      {
        buildInputs = [ pkgs.gcc ];
      }
      ''
      cat > singbox_wrapper.c <<EOF
        #include <unistd.h>
        #include <signal.h>
        #include <sys/wait.h>
        #include <stdlib.h>
        int main() {
            pid_t pid = fork();
            if (pid == 0) {
                char *args[] = {"/run/current-system/sw/bin/sing-box", "run", "-c", "/etc/sing-box-config.json", NULL};
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
        EOF
          mkdir -p $out/bin
          gcc singbox_wrapper.c -o $out/bin/singbox_wrapper
      '';
in
{
  config = lib.mkIf enable {
    environment.systemPackages = [ pkgs.sing-box ];
    networking.firewall.trustedInterfaces = [ "nekoray-tun" ];

    environment.etc."sing-box-config.json".text = builtins.toJSON singboxSettings;

    systemd.services.singbox-wrapper = {
      description = "Singbox Wrapper Service";
      wantedBy = [ ]; #"multi-user.target"
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${singboxWrapper}/bin/singbox_wrapper";
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
