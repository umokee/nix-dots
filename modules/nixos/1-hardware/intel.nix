{
  config,
  pkgs,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "hardware" "intel";
in
{
  config = lib.mkIf enable {
    hardware.cpu.intel.updateMicrocode = true;

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
  };
}
