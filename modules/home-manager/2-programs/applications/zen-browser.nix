{
  config,
  pkgs,
  lib,
  inputs,
  wallpapers,
  conf,
  ...
}:
let
  colors = config.colorScheme.palette;
  wallpaper = wallpapers.${conf.wallpaperName} or wallpapers.backyard;
in
{
  config = {
    home.packages = [
      pkgs.pywalfox-native
      inputs.zen-browser.packages.${pkgs.system}.default
    ];

    home.file.".zen/native-messaging-hosts/pywalfox.json".text = builtins.toJSON {
      name = "pywalfox";
      description = "Pywalfox native messaging host";
      path = "${pkgs.pywalfox-native}/bin/pywalfox";
      type = "stdio";
      allowed_extensions = [ "pywalfox@frewacom.org" ];
    };

    home.file.".cache/wal/colors.json".text = builtins.toJSON {
      wallpaper = "${wallpaper}";
      alpha = "100";
      colors = {
        color0 = "#${colors.base00}";
        color1 = "#${colors.base08}";
        color2 = "#${colors.base0B}";
        color3 = "#${colors.base0A}";
        color4 = "#${colors.base0D}";
        color5 = "#${colors.base0E}";
        color6 = "#${colors.base0C}";
        color7 = "#${colors.base05}";
        color8 = "#${colors.base03}";
        color9 = "#${colors.base05}";
        color10 = "#${colors.base0B}";
        color11 = "#${colors.base0A}";
        color12 = "#${colors.base0D}";
        color13 = "#${colors.base0E}";
        color14 = "#${colors.base0C}";
        color15 = "#${colors.base07}";
      };
    };
  };
}
