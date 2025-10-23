{
  config,
  lib,
  pkgs,
  helpers,
  ...
}:
let
  cfg = {
    name = "Posy_Cursor_Black";
    package = pkgs.posy-cursors;
    size = 24;
  };
in
{
  config = lib.mkIf helpers.isWM {
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = cfg.name;
      package = cfg.package;
      size = cfg.size;
    };

    gtk.cursorTheme = {
      name = cfg.name;
      package = cfg.package;
      size = cfg.size;
    };
  };
}
