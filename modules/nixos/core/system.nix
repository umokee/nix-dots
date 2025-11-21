{
  conf,
  lib,
  helpers,
  pkgs,
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
        extraPackages = with pkgs; [
          intel-gpu-tools
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
          libva
          vulkan-loader
          vulkan-validation-layers
        ];
        extraPackages32 = with pkgs; [
          intel-gpu-tools
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
          libva
        ];
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
 
          http-connections = 128;
          download-attempts = 5;
          connect-timeout = 10;
 
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

      #system.autoUpgrade = {
      #  enable = true;
      #  flake = "/home/user/nix-dots#server";
      #  flags = [
      #    "--update-input"
      #    "nixpkgs"
      #    "--commit-lock-file"
      #  ];
      #  dates = "04:00";
      #  randomizedDelaySec = "45min";
      #  allowReboot = false;
      #};

      documentation = {
        enable = false;
        nixos.enable = false;
        man.enable = false;
        doc.enable = false;
      };

      programs.nix-ld.enable = true;
    })

    (lib.mkIf helpers.isServer {
      #boot.kernelParams = [
      #  "console=tty0"
      #  "console=ttyS0,115200n8"
      #];

      services.xserver.enable = lib.mkForce false;

      services.journald.extraConfig = ''
        SystemMaxUse=500M
        MaxRetentionSec=1week
      '';
    })
  ];
}
