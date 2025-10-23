{
  config,
  lib,
  pkgs,
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
          mode    http
          option  httplog
          option  dontlognull
          timeout connect 5000ms
          timeout client  50000ms
          timeout server  50000ms
          errorfile 400 /etc/haproxy/errors/400.http
          errorfile 403 /etc/haproxy/errors/403.http
          errorfile 408 /etc/haproxy/errors/408.http
          errorfile 500 /etc/haproxy/errors/500.http
          errorfile 502 /etc/haproxy/errors/502.http
          errorfile 503 /etc/haproxy/errors/503.http
          errorfile 504 /etc/haproxy/errors/504.http

        frontend https_front
          bind *:443
          mode tcp
          option tcplog
          
          tcp-request inspect-delay 5s
          tcp-request content accept if { req.ssl_hello_type 1 }
          
          # Определяем VLESS трафик и отправляем на sing-box
          acl is_vless req.ssl_sni -i umkcloud.ru
          
          use_backend vless_backend if is_vless
          default_backend web_backend

        frontend http_front
          bind *:80
          mode http
          
          # Редирект на HTTPS для обычного трафика
          redirect scheme https code 301 if !{ ssl_fc }

        backend vless_backend
          mode tcp
          option tcp-check
          server singbox 127.0.0.1:8443 check

        backend web_backend
          mode tcp
          option tcp-check
          # Отправляем на реальный сайт (steal-oneself)
          server realweb www.github.com:443 check ssl verify none
      '';
    };

    systemd.tmpfiles.rules = [
      "d /etc/haproxy/errors 0755 haproxy haproxy -"
    ];

    systemd.services.haproxy.serviceConfig = {
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/run/haproxy" ];
    };
  };
}
