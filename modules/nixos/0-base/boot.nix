{
  config,
  lib,
  helpers,
  pkgs,
  ...
}:
let
  enable = helpers.hasIn "base" "boot";
in
{
  config = lib.mkIf enable {
    nixpkgs.overlays = [
      (self: super: {
        linuxPackages = super.linuxPackages // {
          kernel = super.linuxPackages.kernel.override {
            structuredExtraConfig = with lib.kernel; {
              HZ_1000 = yes;
              HZ = 1000;
              PREEMPT_FULL = yes;
              IOSCHED_BFQ = yes;
              DEFAULT_BFQ = yes;
              DEFAULT_IOSCHED = "bfq";
              V4L2_LOOPBACK = module;
              HID = yes;
            };
          };
        };
      })
    ];

    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="block", ATTR{queue/scheduler}="bfq"
    '';

    boot.loader.grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    boot.loader.timeout = 3;

    boot = {
      #kernelPackages = if helpers.isDesktop then pkgs.linuxPackages_6_16 else pkgs.linuxPackages;
      tmp.cleanOnBoot = true;
      supportedFilesystems.zfs = lib.mkForce false;
      kernelParams =
        if builtins.elem "kvm-amd" config.boot.kernelModules then [ "amd_pstate=active" "nosplit_lock_mitigate" "clearcpuid=514" ] else [ "nosplit_lock_mitigate" ]++ [
        "quiet"
        "splash"
      ];
      kernel.sysctl = {
        "kernel.split_lock_mitigate" = 0;
        "vm.swappiness" = 10;
        "vm.vfs_cache_pressure" = 50;
        "vm.dirty_bytes" = 268435456;
        "vm.max_map_count" = 16777216;
        "vm.dirty_background_bytes" = 67108864;
        "vm.dirty_writeback_centisecs" = 1500;
        "kernel.nmi_watchdog" = 0;
        "kernel.unprivileged_userns_clone" = 1;
        "kernel.printk" = "3 3 3 3";
        "kernel.kptr_restrict" = 2;
        "kernel.kexec_load_disabled" = 1;
      };

      initrd.verbose = false;
      consoleLogLevel = 3;
    };

    hardware.graphics = {
      enable = true;
      package = pkgs.mesa;
      package32 = pkgs.pkgsi686Linux.mesa;
    };
  };
}
