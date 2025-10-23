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
          timeout connect 30s
          timeout client  1h
          timeout server  1h

        frontend https_front
          bind *:443
          mode tcp
          option tcplog
          
          tcp-request inspect-delay 5s
          tcp-request content accept if { req.ssl_hello_type 1 }
          
          acl is_vless req.ssl_sni -i github.com
          acl is_vless req.ssl_sni -i www.github.com
          acl is_domain req.ssl_sni -i umkcloud.ru
          acl is_domain req.ssl_sni -i www.umkcloud.ru
          
          use_backend xray_backend if is_vless
          use_backend nginx_ssl if is_domain
          default_backend github_backend

        backend xray_backend
          mode tcp
          option tcp-check
          server xray 127.0.0.1:8443 send-proxy-v2

        backend nginx_ssl
          mode tcp
          server nginx 127.0.0.1:8444

        backend github_backend
          mode tcp
          server github github.com:443
      '';
    };

    services.nginx.virtualHosts."umkcloud.ru" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 8444;
          ssl = true;
        }
      ];
      sslCertificate = "/var/lib/acme/umkcloud.ru/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/umkcloud.ru/key.pem";
    };

    systemd.tmpfiles.rules = [
      "d /run/haproxy 0755 haproxy haproxy -"
    ];

    networking.firewall.allowedTCPPorts = [ 443 ];

    systemd.services.haproxy.serviceConfig.SupplementaryGroups = [ "acme" ];
    
    systemd.services.haproxy.wants = [ "acme-umkcloud.ru.service" ];
    systemd.services.haproxy.after = [ "acme-umkcloud.ru.service" ];
  };
}
