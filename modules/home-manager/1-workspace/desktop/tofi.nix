{
  config,
  lib,
  helpers,
  conf,
  ...
}:
let
  colors = config.colorScheme.palette;
in
{
  programs.tofi = lib.mkIf (!helpers.isDwl) {
    enable = true;

    settings = {
      anchor = "top";
      width = "100%";
      height = 40;
      margin-top = 0;
      margin-bottom = 0;

      border-width = 0;
      outline-width = 0;

      horizontal = true;
      result-spacing = 25;
      num-results = 8;

      font = "JetBrainsMono Nerd Font Mono";
      font-style = "Bold";
      font-size = 12;

      # Цвета из nix-colors (base16)
      background-color = "#${colors.base00}"; # Фон
      text-color = "#${colors.base05}"; # Основной текст
      prompt-color = "#${colors.base0D}"; # Промпт (синий)
      placeholder-color = "#${colors.base03}"; # Placeholder
      selection-color = "#${colors.base0D}"; # Выбранный элемент (синий)
      selection-background = "#${colors.base02}"; # Фон выбранного
      selection-match-color = "#${colors.base0B}"; # Совпадения (зелёный)

      # Дополнительно
      prompt-text = "run: ";
      placeholder-text = "...";

      # Поведение
      fuzzy-match = true;
      hide-cursor = true;
      history = true;

      # Производительность
      drun-launch = true;
      terminal = conf.default.terminal;
    };
  };

  home.activation.clearTofiCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f ${config.home.homeDirectory}/.cache/tofi-drun
  '';
}
