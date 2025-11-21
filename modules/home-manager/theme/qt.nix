{
  lib,
  pkgs,
  helpers,
  ...
}:
{
  config = lib.mkIf helpers.isWM {
    home.packages = with pkgs; [
      libsForQt5.qt5ct
      qt6ct
      adwaita-qt
      adwaita-qt6
    ];

    qt = {
      enable = true;
      platformTheme.name = "qt6ct";

      style = {
        name = "Adwaita-dark";
        package = pkgs.adwaita-qt6;
      };
    };

    # TODO ПЕРЕМЕСТИТЬ ПЕРЕМЕННЫЕ
    home.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_STYLE_OVERRIDE = "Adwaita-dark";
    };
  };
}
