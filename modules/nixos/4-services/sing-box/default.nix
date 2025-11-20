{
  pkgs,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "sing-box";

  rule_sets = import ./rule-sets.nix { inherit pkgs; };
  dns = import ./dns.nix { };
  inbounds = import ./inbounds.nix { };
  outbounds = import ./outbounds.nix { };
  route = import ./routes.nix { inherit rule_sets; };
  singboxWrapper = import ./wrapper.nix { inherit pkgs; };

  singboxSettings = {
    log = {
      level = "warn";
      output = "box.log";
      timestamp = true;
    };

    experimental = {
      cache_file = {
        enabled = true;
        path = "cache.db";
      };
    };

    inherit dns inbounds outbounds route;
  };
in
{
  config = lib.mkIf enable {
    environment.systemPackages = [ pkgs.sing-box ];
    networking.firewall.trustedInterfaces = [ "nekoray-tun" ];

    environment.etc."sing-box-config.json".text = builtins.toJSON singboxSettings;

    systemd.services.singbox-wrapper = {
      description = "Singbox Wrapper Service";
      wantedBy = [ ];
      after = [ "network.target" ];

      restartIfChanged = false;
      stopIfChanged = true;

      serviceConfig = {
        ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /etc/sing-box-config.json";
        Restart = "on-failure";
        RestartSec = 5;
        StandardOutput = "journal";
        StandardError = "journal";

        KillSignal = "SIGTERM";
        TimeoutStopSec = "10s";
        KillMode = "mixed";

        AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";

        ExecStopPost = "${pkgs.iproute2}/bin/ip link delete nekoray-tun || true";
      };
    };
  };
}
