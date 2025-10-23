{
  config,
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "base" "security";
in
{
  config = lib.mkIf enable {
    security.sudo = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = true;
      extraConfig = ''
        Defaults timestamp_timeout=5
        Defaults lecture="never"
      '';
    };

    security.polkit.enable = true;

    #users.groups = {
    #  networkmanager = { };
    #  wheel = { };
    #  audio = { };
    #  video = { };
    #};

    security.pam.loginLimits = [
      {
        domain = "*";
        item = "nice";
        type = "soft";
        value = "-20";
      }
      {
        domain = "*";
        item = "nice";
        type = "hard";
        value = "-20";
      }
    ];

  };
}
