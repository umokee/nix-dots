{
  conf,
  pkgs,
  ...
}:
{
  config = {
    home.sessionPath = [
      "$HOME/.local/bin"
    ];

    home.sessionVariables = {
      DOTS = "$HOME/nixos";
      TERMINAL = conf.default.terminal;
      EDITOR = conf.default.editor;
      VISUAL = conf.default.visual;
      BROWSER = conf.default.browser;
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}";
    };
  };
}
