{
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "hardware" "amd";
in
{
  config = lib.mkIf enable {
    boot.kernelParams = [
      "amd_pstate=active"
      "amdgpu.dcdebugmask=0x10"
    ]
    ++ lib.optionals helpers.isLaptop [
      "processor.max_cstate=5"
    ];

    services.xserver.videoDrivers = [ "amdgpu" ];

    hardware = {
      cpu.amd.updateMicrocode = true;
      enableRedistributableFirmware = true;

      graphics = {
        enable = true;
        enable32Bit = true;

        extraPackages = with pkgs; [
          mesa
          vulkan-loader
          vulkan-validation-layers
        ];
      };
    };

    environment.sessionVariables = {
      MESA_LOADER_DRIVER_OVERRIDE = "radeonsi";
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";
    };

    environment.systemPackages =
      with pkgs;
      [
        libva-utils
        vulkan-tools
        vdpauinfo
        clinfo
      ]
      ++ lib.optionals helpers.isLaptop [
        ryzenadj
        zenmonitor
      ];
  };
}
