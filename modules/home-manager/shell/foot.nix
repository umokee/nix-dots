{
  config,
  pkgs,
  ...
}:
{
  programs.foot = {
    enable = true;
    package = pkgs.foot;

    settings = {
      main = {
        term = "xterm-256color";

        font = "JetBrainsMono Nerd Font:size=16";
        font-bold = "JetBrainsMono Nerd Font:style=Bold:size=16";
        font-italic = "JetBrainsMono Nerd Font:style=Italic:size=16";
        font-bold-italic = "JetBrainsMono Nerd Font:style=Bold Italic:size=16";

        pad = "15x15 center";
        dpi-aware = "yes";
        selection-target = "clipboard";
      };

      colors = {
        alpha = 0.95;

        # Базовые цвета из colorscheme
        foreground = "${config.colorScheme.palette.base05}";
        background = "${config.colorScheme.palette.base00}";

        # Обычные цвета (regular)
        regular0 = "${config.colorScheme.palette.base00}"; # black
        regular1 = "${config.colorScheme.palette.base08}"; # red
        regular2 = "${config.colorScheme.palette.base0B}"; # green
        regular3 = "${config.colorScheme.palette.base0A}"; # yellow
        regular4 = "${config.colorScheme.palette.base0D}"; # blue
        regular5 = "${config.colorScheme.palette.base0E}"; # magenta
        regular6 = "${config.colorScheme.palette.base0C}"; # cyan
        regular7 = "${config.colorScheme.palette.base05}"; # white

        # Яркие цвета (bright)
        bright0 = "${config.colorScheme.palette.base03}"; # bright black
        bright1 = "${config.colorScheme.palette.base08}"; # bright red
        bright2 = "${config.colorScheme.palette.base0B}"; # bright green
        bright3 = "${config.colorScheme.palette.base0A}"; # bright yellow
        bright4 = "${config.colorScheme.palette.base0D}"; # bright blue
        bright5 = "${config.colorScheme.palette.base0E}"; # bright magenta
        bright6 = "${config.colorScheme.palette.base0C}"; # bright cyan
        bright7 = "${config.colorScheme.palette.base07}"; # bright white

        # Цвет выделения
        selection-foreground = "${config.colorScheme.palette.base00}";
        selection-background = "${config.colorScheme.palette.base05}";
      };

      scrollback = {
        # История прокрутки
        lines = 10000;

        # Множитель прокрутки
        multiplier = 3.0;
      };

      cursor = {
        # Стиль курсора: block, beam, underline
        style = "block";

        # Мигание курсора
        blink = "no";

        # Курсор в неактивном окне: unchanged, hollow, none
        unfocused-style = "hollow";
      };

      mouse = {
        # Скрытие курсора при вводе
        hide-when-typing = "yes";
      };

      mouse-bindings = {
        # Отключаем расширение выделения правой кнопкой
        select-extend = "none";

        # Назначаем вставку на правую кнопку
        # Можно использовать primary-paste или clipboard-paste
        clipboard-paste = "BTN_RIGHT";

        # Стандартные привязки
        select-begin = "BTN_LEFT";
        select-begin-block = "Control+BTN_LEFT";
        select-word = "BTN_LEFT-2";

        # Средняя кнопка для вставки из primary selection
        primary-paste = "BTN_MIDDLE";
      };
    };
  };
}
