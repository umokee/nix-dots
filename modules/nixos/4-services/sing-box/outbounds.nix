{ ... }:
[
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
]
