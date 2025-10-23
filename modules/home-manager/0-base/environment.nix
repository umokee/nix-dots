{
  config,
  lib,
  conf,
  helpers,
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
    };
  };
}
