{
  config,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "workspace" "themes";
  colors = config.colorScheme.palette;
in
{
  config = lib.mkIf enable {
    wayland.windowManager.hyprland.settings = {
      general = {
        "col.active_border" = "rgba(${colors.base0D}ee)";
        "col.inactive_border" = "rgba(${colors.base03}ee)";
      };

      misc = {
        background_color = "rgba(${colors.base00}ee)";
      };
    };
  };
}
