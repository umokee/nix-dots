{
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "workspace" "display-manager";
in
{
  config = lib.mkIf enable {
    #services.getty.autologinUser = conf.username;

    #services.displayManager.ly = {
    #  enable = false;
    #  settings = {
    #    animation = "none";
    #    clock = "%c";
    #    bigclock = true;
    #    hide_borders = true;
    #    hide_f1_commands = true;
    #  };
    #};
  };
}
