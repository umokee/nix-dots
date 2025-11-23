{
  conf,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "base" "system";
in
{
  config = lib.mkMerge [
    (lib.mkIf enable {
      time.hardwareClockInLocalTime = true;

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = if helpers.isServer then 150 else 25;
        priority = 5;
      };

      nix = {
        settings = {
          trusted-users = [
            "root"
            conf.username
          ];
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];

          substituters = [
            "https://cache.nixos.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:..."
          ];
          fallback = true;
          max-jobs = "auto";
          cores = 0;

          connect-timeout = 60;
          stalled-download-timeout = 300;
          download-attempts = 3;

          show-trace = true;
          keep-outputs = false;
          keep-derivations = false;
        };

        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };

        optimise = {
          automatic = true;
          dates = [ "weekly" ];
        };
      };

      documentation = {
        enable = false;
        nixos.enable = false;
        man.enable = false;
        doc.enable = false;
      };

      programs.nix-ld.enable = true;
    })

    (lib.mkIf helpers.isServer {
      services.xserver.enable = lib.mkForce false;

      services.journald.extraConfig = ''
        SystemMaxUse=500M
        MaxRetentionSec=1week
      '';
    })
  ];
}
