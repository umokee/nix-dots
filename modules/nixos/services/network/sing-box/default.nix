{
  pkgs,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "sing-box";
in
{
  config = lib.mkIf enable {
    environment.systemPackages = [ pkgs.sing-box ];
    networking.firewall.trustedInterfaces = [ "nekoray-tun" ];

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
