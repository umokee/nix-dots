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
    services.dunst.settings = {
      global = {
        frame_color = "#${colors.base0D}";
        separator_color = "#${colors.base0D}";
      };

      urgency_low = {
        background = "#${colors.base01}";
        foreground = "#${colors.base04}";
        frame_color = "#${colors.base03}";
      };

      urgency_normal = {
        background = "#${colors.base01}";
        foreground = "#${colors.base05}";
        frame_color = "#${colors.base0D}";
      };

      urgency_critical = {
        background = "#${colors.base01}";
        foreground = "#${colors.base05}";
        frame_color = "#${colors.base08}";
      };
    };
  };
}
