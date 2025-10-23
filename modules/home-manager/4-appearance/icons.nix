{
  pkgs,
  lib,
  helpers,
  ...
}:
{
  config = lib.mkIf helpers.isWM {
    gtk = {
      enable = true;
      iconTheme = {
        name = "Tela-circle";
        package = pkgs.tela-circle-icon-theme;
      };
    };
  };
}
