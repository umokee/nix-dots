{ ... }:
[
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
]
