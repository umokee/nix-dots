{
  pkgs,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "base" "fonts";
in
{
  config = lib.mkIf enable {
    fonts = {
      packages = with pkgs; [
        vistafonts
        corefonts
        dejavu_fonts
        liberation_ttf
        noto-fonts
        noto-fonts-emoji
        nerd-fonts.jetbrains-mono
      ];

      fontconfig = {
        enable = true;
        antialias = true;
        hinting.enable = true;

        defaultFonts = {
          serif = [ "DejaVu Serif" ];
          sansSerif = [ "DejaVu Sans" ];
          monospace = [ "JetBrainsMono Nerd Font" ];
        };
      };
    };
  };
}
