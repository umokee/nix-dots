{
  pkgs,
  lib,
  conf,
  helpers,
  wallpapers,
  ...
}:
let
  enable = helpers.hasIn "workspace" "wallpapers";
  wallpaper = wallpapers.${conf.wallpaperName} or wallpapers.backyard;
in
{
  config = lib.mkIf enable (
    lib.mkMerge [
      (lib.mkIf helpers.isWayland {
        home.packages = [ pkgs.swaybg ];

        systemd.user.services.swaybg-daemon = {
          Unit = {
            Description = "Swaybg Wallpaper Daemon";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill";
            Restart = "on-failure";
            RestartSec = "3";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      })

      (lib.mkIf helpers.isX11 {
        home.packages = [ pkgs.feh ];

        systemd.user.services.feh-daemon = {
          Unit = {
            Description = "Feh Wallpaper Daemon";
            After = [ "graphical-session-pre.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.feh}/bin/feh --bg-fill ${wallpaper}";
            RemainAfterExit = true;
            Restart = "on-failure";
            RestartSec = "3";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      })
    ]
  );
}
