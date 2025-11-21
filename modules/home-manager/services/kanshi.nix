{
  lib,
  helpers,
  ...
}:
{
  config = lib.mkIf (helpers.isWM && helpers.isWayland) {
    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";

      settings = [
        {
          profile.name = "desktop";
          profile.outputs = [
            {
              criteria = "DP-3";
              mode = "2560x1440@165Hz";
              position = "0,0";
              scale = 1.0;
            }
            {
              criteria = "DP-4";
              mode = "1920x1080@100Hz";
              transform = "270";
              position = "2560,0";
              scale = 1.0;
            }
            {
              criteria = "HDMI-A-5";
              mode = "1920x1080@60Hz";
              position = "640,1440";
              scale = 1.0;
            }
          ];
        }
        {
          profile.name = "laptop";
          profile.outputs = [
            {
              criteria = "eDP-1";
              mode = "2560x1440@48Hz";
              position = "0,0";
              scale = 1.0;
            }
          ];
        }
      ];
    };
  };
}
