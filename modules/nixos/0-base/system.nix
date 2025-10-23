{
  config,
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
          #optimise = {
          #  automatic = true;
          #  dates = [ "weekly" ];
          #};
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };

        #gc = {
        #  automatic = true;
        #  dates = [ "weekly" ];
        #  options = "--delete-older-than 7d";
        #};
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
      #boot.kernelParams = [
      #  "console=tty0"
      #  "console=ttyS0,115200n8"
      #];
      
      services.xserver.enable = lib.mkForce false;
      
      services.journald.extraConfig = ''
        SystemMaxUse=500M
        MaxRetentionSec=1week
      '';
      
      boot.kernel.sysctl = {
        "net.ipv4.tcp_fastopen" = 3;
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "fq";
        "net.ipv4.ip_forward" = 1;
      };
    })
  ];
}
