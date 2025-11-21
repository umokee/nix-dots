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

    STOP_CHARGE_THRESH_BAT0 = 0;

    WIFI_PWR_ON_AC = "off";
    WIFI_PWR_ON_BAT = "on";

    SOUND_POWER_SAVE_ON_AC = 10;
    SOUND_POWER_SAVE_ON_BAT = 1;

    USB_AUTOSUSPEND = 1;
    USB_BLACKLIST_BTUSB = 0;
    USB_BLACKLIST_PHONE = 0;
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

      {
        services.tlp = {
          enable = true;
          settings = tlpSettings;
        };

        services.auto-cpufreq.enable = false;
        services.power-profiles-daemon.enable = false;
      }
    ]
  );
}
