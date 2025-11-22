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
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];

          http-connections = 25;
          download-attempts = 5;
          connect-timeout = 5;
          stalled-download-timeout = 300;

          fallback = true;

          max-jobs = "auto";
          cores = 0;

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
