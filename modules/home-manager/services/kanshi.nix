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
              scale = 1.25;
            }
            {
              criteria = "DP-4";
              mode = "1920x1080@100Hz";
              transform = "270";
              position = "2048,0";
              scale = 1.0;
            }
            {
              criteria = "HDMI-A-5";
              mode = "1920x1080@60Hz";
              position = "512,1152";
              scale = 1.25;
            }
          ];
        }
        {
          profile.name = "laptop";
          profile.outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
              scale = 1.25;
            }
          ];
        }
      ];
    };
  };
}
