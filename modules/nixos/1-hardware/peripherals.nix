{
  lib,
  helpers,
  conf,
  pkgs,
  ...
}:
let
  enable = helpers.hasIn "hardware" "keyboard-mouse";
in
{
  config = lib.mkIf enable {
    services.xserver.xkb = {
      layout = "us,ru";
      variant = "";
      options = "grp:ctrl_shift_toggle";
    };

    console.keyMap = lib.mkDefault (lib.head (lib.splitString "," "us"));

    services.libinput = {
      enable = true;
      mouse = {
        accelProfile = "adaptive";
        accelSpeed = "0.0";
      };

      touchpad = {
        naturalScrolling = true;
        tapping = true;
        clickMethod = "clickfinger";
      };
    };

    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="input", TAG+="uaccess", TAG+="udev-acl"
    '';

    users.users.${conf.username}.extraGroups = [
      "plugdev"
      "uaccess"
    ];

    systemd.services.reload-libinput = {
      description = "Reload libinput after udev changes";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-udevd.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/udevadm trigger --subsystem-match=input";
        RemainAfterExit = true;
      };
    };
  };
}
