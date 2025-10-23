{
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "haproxy";
in
{
  config = lib.mkIf enable {
    services.haproxy = {
      enable = true;
      
      config = ''
        global
          daemon
          maxconn 4096
          log /dev/log local0 info
          stats socket /run/haproxy/admin.sock mode 660 level admin
          stats timeout 30s
          tune.ssl.default-dh-param 2048

        defaults
          log     global
          mode    tcp
          option  tcplog
          timeout connect 5000ms
          timeout client  50000ms
          timeout server  50000ms

        frontend https_front
          bind *:443
          mode tcp
          option tcplog
          
          tcp-request inspect-delay 5s
          tcp-request content accept if { req.ssl_hello_type 1 }
          
          acl is_vless req.ssl_sni -i 185.223.169.86
          acl is_vless req.ssl_sni -i umkcloud.ru
          acl is_vless req.ssl_sni -i github.com
          acl is_vless req.ssl_sni -i www.github.com
          
          use_backend xray_backend if is_vless
          default_backend github_backend

        backend xray_backend
          mode tcp
          option tcp-check
          server xray 127.0.0.1:8443 send-proxy-v2

        backend github_backend
          mode tcp
          option ssl-hello-chk
          server github github.com:443 check
      '';
    };

    systemd.tmpfiles.rules = [
      "d /run/haproxy 0755 haproxy haproxy -"
    ];

    networking.firewall.allowedTCPPorts = [ 443 ];

    systemd.services.haproxy.serviceConfig = {
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/run/haproxy" ];
    };
  };
}
