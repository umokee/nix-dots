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
        ++ lib.optionals (helpers.hasIn "services" "postgresql") [
          5432
        ]
        ++ lib.optionals (helpers.hasIn "services" "ms-sql") [
          1433
        ];

        allowedUDPPorts = [ 443 ];

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
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
      
      "net.ipv4.tcp_fastopen" = 3;
      
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.ipv4.tcp_no_metrics_save" = 1;
      "net.ipv4.tcp_notsent_lowat" = 16384;
      
      "net.ipv4.tcp_keepalive_time" = 300;
      "net.ipv4.tcp_keepalive_intvl" = 30;
      "net.ipv4.tcp_keepalive_probes" = 3;
      
      "net.ipv4.tcp_mtu_probing" = 1;
      
      "net.ipv4.tcp_window_scaling" = 1;
      "net.ipv4.tcp_timestamps" = 1;
      "net.ipv4.tcp_sack" = 1;
      "net.ipv4.tcp_fack" = 1;
      
      "net.ipv4.tcp_ecn" = 1;
      
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.ipv6.conf.default.disable_ipv6" = 1;
      
      "net.netfilter.nf_conntrack_max" = 262144;
      "net.netfilter.nf_conntrack_tcp_timeout_established" = 7200;
    } // lib.optionalAttrs helpers.isDesktop {
      "net.core.rmem_max" = 134217728;  # 128MB
      "net.core.wmem_max" = 134217728;  # 128MB
      "net.ipv4.tcp_rmem" = "4096 131072 134217728";
      "net.ipv4.tcp_wmem" = "4096 131072 134217728";
      "net.ipv4.udp_rmem_min" = 16384;
      "net.ipv4.udp_wmem_min" = 16384;
      
      "net.core.netdev_max_backlog" = 16384;
      "net.core.somaxconn" = 4096;
      
      "net.ipv4.tcp_low_latency" = 1;
      
      #"net.ipv4.ip_local_port_range" = "10000 65535";
      
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 15;
      
      "net.ipv4.tcp_frto" = 2;
      "net.ipv4.tcp_moderate_rcvbuf" = 1;
    } // lib.optionalAttrs helpers.isServer {
      "net.ipv4.ip_forward" = 1;
      
      "net.core.rmem_max" = 268435456;  # 256MB
      "net.core.wmem_max" = 268435456;  # 256MB
      "net.ipv4.tcp_rmem" = "4096 131072 268435456";
      "net.ipv4.tcp_wmem" = "4096 131072 268435456";
      "net.ipv4.udp_rmem_min" = 32768;
      "net.ipv4.udp_wmem_min" = 32768;
      
      "net.core.netdev_max_backlog" = 65536;
      "net.core.somaxconn" = 65536;
      
      "net.ipv4.ip_local_port_range" = "1024 65535";
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_synack_retries" = 2;
      "net.ipv4.tcp_syn_retries" = 2;
      
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 10;
      
      "net.ipv4.tcp_max_tw_buckets" = 2000000;
      "net.ipv4.tcp_tw_recycle" = 0;
      
      "net.ipv4.tcp_max_orphans" = 262144;
      
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      
      "net.ipv4.tcp_mem" = "65536 131072 262144";
      "net.ipv4.udp_mem" = "65536 131072 262144";
      
      "fs.file-max" = 2097152;
    };
  };
}
