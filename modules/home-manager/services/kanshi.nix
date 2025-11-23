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
              criteria = "Shenzhen KTC Technology Group VG2710PQU 0x00000001";
              mode = "2560x1440@165.00";
              position = "0,0";
              scale = 1.0;
            }
            {
              criteria = "CMT GA241 CMI231603659";
              mode = "1920x1080@60.00";
              transform = "270";
              position = "2560,0";
              scale = 1.0;
            }
            {
              criteria = "GWD ARZOPA 0000000713942";
              mode = "1920x1080@60.00";
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
              mode = "2560x1440@48.00";
              position = "0,0";
              scale = 1.0;
            }
          ];
        }
      ];
    };
  };
}
