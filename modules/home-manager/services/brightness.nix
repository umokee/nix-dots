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
      Unit = {
        Description = "Set brightness on startup";
        After = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl set 50%";
        RemainAfterExit = true;
      };
    };
  };
}
