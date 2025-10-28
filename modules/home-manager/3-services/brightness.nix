{
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "brightnessctl";
in
{
  config = lib.mkIf enable {
    home.packages = [ pkgs.brightnessctl ];

    systemd.user.services.brightness = {
      description = "Set screen brightness";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl set 50%";
        RemainAfterExit = true;
      };
    };
  };
}
