{ rule_sets, ... }:
{
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
      ];
      outbound = "proxy";
    }
    {
      # КРИТИЧНО: NixOS cache ВСЕГДА напрямую (не через proxy)
      # Предотвращает зависание при nixos-rebuild
      domain_suffix = [
        ".nixos.org"
        ".cachix.org"
        "cache.nixos.org"
        "nix-community.cachix.org"
      ];
      outbound = "direct";
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

        "^(.+\\.)?sheets\\.google\\.com$"
        "^(.+\\.)?forms\\.google\\.com$"
        "^(.+\\.)?docs\\.google\\.com$"
        "^(.+\\.)?drive\\.google\\.com$"
        "^(.+\\.)?accounts\\.google\\.com$"
        "^(.+\\.)?apis\\.google\\.com$"
        "^(.+\\.)?googleapis\\.com$"
        "^(.+\\.)?googleusercontent\\.com$"
        "^(.+\\.)?gstatic\\.com$"
        "^(.+\\.)?gnusenpai\\.net$"
        "^(.+\\.)?typingstudy\\.com$"
        "^(.+\\.)?typingclub\\.com$"
        "^(.+\\.)?typing\\.com$"
        "^(.+\\.)?penpot\\.app$"
        "^(.+\\.)?diagrams\\.net$"
        "^(.+\\.)?draw\\.io$"
        "^(.+\\.)?creately\\.com$"
        "^(.+\\.)?yworks\\.com$"
        "^(.+\\.)?whimsical\\.com$"
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
}
