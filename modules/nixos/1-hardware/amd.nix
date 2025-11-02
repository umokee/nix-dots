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
    boot.blacklistedKernelModules = [ ];

    environment.variables = {
      # Отключи Intel иначе Mango найдёт его вместо AMD
      LIBGL_DRIVERS_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
    };

    boot.kernelParams = [
      "amd_pstate=active"
      "amdgpu.dcdebugmask=0x10"
    ]
    ++ lib.optionals helpers.isLaptop [
      "processor.max_cstate=5"
    ];

    hardware = {
      cpu.amd.updateMicrocode = true;
      enableRedistributableFirmware = true;

      graphics = {
        enable = true;
        enable32Bit = true;

        extraPackages = with pkgs; [
          mesa

          #libva-mesa-driver
          libva-utils

          vulkan-loader
          vulkan-validation-layers
        ];
      };
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";
      MESA_DRIVER_OVERRIDE = "radeonsi";
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
