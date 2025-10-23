{
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "hardware" "power-management";

  laptopTlpSettings = {
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 0;

    CPU_MIN_PERF_ON_AC = 0;
    CPU_MAX_PERF_ON_AC = 90;
    CPU_MIN_PERF_ON_BAT = 0;
    CPU_MAX_PERF_ON_BAT = 40;

    #START_CHARGE_THRESH_BAT0 = 70;
    STOP_CHARGE_THRESH_BAT0 = 0;

    WIFI_PWR_ON_AC = "off";
    WIFI_PWR_ON_BAT = "on";

    SOUND_POWER_SAVE_ON_AC = 10;
    SOUND_POWER_SAVE_ON_BAT = 1;

    USB_AUTOSUSPEND = 1;
    USB_BLACKLIST_BTUSB = 0;
    USB_BLACKLIST_PHONE = 0;

    #SATA_LINKPWR_ON_AC = "med_power_with_dipm";
    #SATA_LINKPWR_ON_BAT = "min_power";

    #PCIE_ASPM_ON_AC = "default";
    #PCIE_ASPM_ON_BAT = "powersupersave";

    #RUNTIME_PM_ON_AC = "auto";
    #RUNTIME_PM_ON_BAT = "auto";

    #RESTORE_DEVICE_STATE_ON_STARTUP = 0;
    #DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth wifi";
    #DEVICES_TO_ENABLE_ON_STARTUP = "";
  };

  desktopTlpSettings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "performance";

    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "performance";

    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 1;

    CPU_MIN_PERF_ON_AC = 0;
    CPU_MAX_PERF_ON_AC = 100;
    CPU_MIN_PERF_ON_BAT = 0;
    CPU_MAX_PERF_ON_BAT = 100;

    WIFI_PWR_ON_AC = "off";
    WIFI_PWR_ON_BAT = "off";

    SOUND_POWER_SAVE_ON_AC = 0;
    SOUND_POWER_SAVE_ON_BAT = 0;

    USB_AUTOSUSPEND = 0;

    #SATA_LINKPWR_ON_AC = "max_performance";
    #SATA_LINKPWR_ON_BAT = "max_performance";

    #PCIE_ASPM_ON_AC = "performance";
    #PCIE_ASPM_ON_BAT = "performance";

    #RUNTIME_PM_ON_AC = "on";
    #RUNTIME_PM_ON_BAT = "on";
  };

  tlpSettings = if helpers.isLaptop then laptopTlpSettings else desktopTlpSettings;
in
{
  config = lib.mkIf enable (
    lib.mkMerge [
      {
        powerManagement = {
          enable = true;
          cpuFreqGovernor = if helpers.isLaptop then "schedutil" else "performance";
          powertop.enable = helpers.isLaptop;
        };

        environment.systemPackages = with pkgs; [
          powertop
          acpi
          tlp
        ];
      }

      (lib.mkIf helpers.isLaptop {
        services.tlp = {
          enable = true;
          settings = tlpSettings;
        };

        services.auto-cpufreq.enable = false;
        services.power-profiles-daemon.enable = false;
      })

      (lib.mkIf helpers.isDesktop {
        services.tlp = {
          enable = true;
          settings = tlpSettings;
        };

        services.auto-cpufreq.enable = false;
        services.power-profiles-daemon.enable = false;
      })
    ]
  );
}
