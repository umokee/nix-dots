{
  lib,
  conf,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "base" "network";
in
{
  config = lib.mkIf enable {
    networking = {
      hostName = conf.hostname;
      networkmanager.enable = true;

      firewall = {
        enable = helpers.isServer;

        allowedTCPPorts = [
          22
          80
          443
        ]
        ++ lib.optionals helpers.hasIn "services" "postgresql" [
          5432
        ]
        ++ lib.optionals helpers.hasIn "services" "ms-sql" [
          1433
        ];

        allowedUDPPorts = [ ];

        allowPing = true;

        interfaces = {
          "lo" = {
            allowedTCPPorts = [ ];
            allowedUDPPorts = [ ];
          };
        };
      };
    };

    boot.kernel.sysctl = {
      # Enable BBR
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
      "net.ipv4.ip_forward" = 1;

      # Защита от IP spoofing
      #"net.ipv4.conf.all.rp_filter" = 1;
      #"net.ipv4.conf.default.rp_filter" = 1;

      # Игнорировать ICMP redirects
      #"net.ipv4.conf.all.accept_redirects" = 0;
      #"net.ipv4.conf.default.accept_redirects" = 0;
      #"net.ipv4.conf.all.secure_redirects" = 0;
      #"net.ipv4.conf.default.secure_redirects" = 0;
      #"net.ipv6.conf.all.accept_redirects" = 0;
      #"net.ipv6.conf.default.accept_redirects" = 0;

      # Не отправлять ICMP redirects
      #"net.ipv4.conf.all.send_redirects" = 0;
      #"net.ipv4.conf.default.send_redirects" = 0;

      # Игнорировать source routed packets
      #"net.ipv4.conf.all.accept_source_route" = 0;
      #"net.ipv4.conf.default.accept_source_route" = 0;
      #"net.ipv6.conf.all.accept_source_route" = 0;
      #"net.ipv6.conf.default.accept_source_route" = 0;

      # Защита от SYN flood
      #"net.ipv4.tcp_syncookies" = 1;
      #"net.ipv4.tcp_syn_retries" = 2;
      #"net.ipv4.tcp_synack_retries" = 2;
      #"net.ipv4.tcp_max_syn_backlog" = 4096;

      # Защита от TIME-WAIT assassination
      #"net.ipv4.tcp_rfc1337" = 1;

      # Логирование подозрительных пакетов
      #"net.ipv4.conf.all.log_martians" = 1;
      #"net.ipv4.conf.default.log_martians" = 1;

      # Отключаем IPv6 (если не используется)
      # "net.ipv6.conf.all.disable_ipv6" = 1;
      # "net.ipv6.conf.default.disable_ipv6" = 1;
    };
  };
}
