{
  lib,
  helpers,
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
  };
}
