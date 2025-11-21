{
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "programs" "gaming";
in
{
  config = lib.mkIf enable {
    environment.systemPackages = with pkgs; [
      (lutris.override {
        extraLibraries = p: [
          p.libadwaita
          p.gtk4
        ];
      })

      glxinfo
      heroic
      (bottles.override {
        removeWarningPopup = true;
      })
      vkd3d-proton
      dxvk
      joystickwake
      mangohud
      oversteer
      umu-launcher
      wineWowPackages.staging
      winetricks
      openrgb-with-all-plugins

      xorg.xrdb
    ];

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
    services.hardware.openrgb.enable = true;
    services.udev.extraRules = ''
      # USB
      ATTRS{name}=="Sony Interactive Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ATTRS{name}=="Sony Interactive Entertainment DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      # Bluetooth
      ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      ATTRS{name}=="DualSense Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';

    hardware.steam-hardware.enable = true;
    hardware.opentabletdriver.enable = true;

    programs.gamemode.enable = true;

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      package = pkgs.steam.override {
        extraEnv = {
          OBS_VKCAPTURE = true;
        };
      };
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
        proton-cachyos
      ];
    };
  };
}
