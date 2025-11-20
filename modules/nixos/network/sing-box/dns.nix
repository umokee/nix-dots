{ ... }:
{
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
      # КРИТИЧНО: NixOS cache должен резолвиться напрямую!
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
}
