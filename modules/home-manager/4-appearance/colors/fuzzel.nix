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
    programs.fuzzel.settings = {
      colors = {
        background = "${colors.base00}ff";
        text = "${colors.base05}ff";
        prompt = "${colors.base0D}ff";
        placeholder = "${colors.base03}ff";
        input = "${colors.base05}ff";
        match = "${colors.base08}ff";
        selection = "${colors.base02}ff";
        selection-text = "${colors.base05}ff";
        selection-match = "${colors.base08}ff";
        counter = "${colors.base03}ff";
        border = "${colors.base0D}ff";
      };
    };
  };
}
