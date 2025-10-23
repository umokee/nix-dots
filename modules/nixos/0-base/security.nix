{
  lib,
  helpers,
  conf,
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
      wheelNeedsPassword = !helpers.isServer;
      extraConfig = ''
        Defaults timestamp_timeout=5
        Defaults lecture="never"
      '';

      extraRules = lib.optionals helpers.isServer [
        {
          users = [ conf.username ];
          commands = [
            {
              command = "/run/current-system/sw/bin/systemd-run";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/nix-env";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/nixos-rebuild";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/nix/store/*-nixos-system-*/bin/switch-to-configuration";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/bin/switch-to-configuration";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
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
