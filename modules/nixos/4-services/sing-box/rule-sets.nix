{ pkgs, ... }:
{
  antizapret = pkgs.fetchurl {
    url = "https://github.com/savely-krasovsky/antizapret-sing-box/releases/latest/download/antizapret.srs";
    sha256 = "sha256-rU9fW8VM+/hUrniQg9BBw7ZFMD+sY49GF4XTBdtnd64=";
  };

  refilter_domains = pkgs.fetchurl {
    url = "https://github.com/1andrevich/Re-filter-lists/releases/latest/download/ruleset-domain-refilter_domains.srs";
    sha256 = "sha256-wZJpqcz225XxFnXKs1kUAF+9UdcaDWQZWua5CQ4fSTw=";
  };

  refilter_ipsum = pkgs.fetchurl {
    url = "https://github.com/1andrevich/Re-filter-lists/releases/latest/download/ruleset-ip-refilter_ipsum.srs";
    sha256 = "sha256-Rt34UdnrYU5/kVak7PsNRq3BBY+A+DEPJtoFrrQI8Os=";
  };

  geoip-ru = pkgs.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/SagerNet/sing-geoip@rule-set/geoip-ru.srs";
    sha256 = "sha256-pCwbEX/ltxaLTFgM26E6j1N4ANgl7isazbhTScewkw8=";
  };
}
