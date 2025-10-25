{
  config,
  lib,
  pkgs,
  helpers,
  ...
}:
let
  directory = "${config.home.homeDirectory}/Pictures/Screenshots";

  selectedTool = if helpers.isWayland then "grim" else "maim";
  filename = "\\$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S).png";

  screenshotCommands = {
    grim = {
      fullscreen = "${pkgs.grim}/bin/grim - | ${pkgs.coreutils}/bin/tee '${directory}/${filename}' | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png";
      area = "${pkgs.grim}/bin/grim -g \"\\$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.coreutils}/bin/tee '${directory}/${filename}' | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png";
      clipboard = "${pkgs.grim}/bin/grim -g \"\\$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png";
      window = "${pkgs.hyprland}/bin/hyprctl -j activewindow | ${pkgs.jq}/bin/jq -r '\"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"' | ${pkgs.grim}/bin/grim -g - - | ${pkgs.coreutils}/bin/tee '${directory}/${filename}' | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png";
    };

    maim = {
      fullscreen = "${pkgs.maim}/bin/maim '${directory}/${filename}'";
      area = "${pkgs.maim}/bin/maim -s '${directory}/${filename}'";
      clipboard = "${pkgs.maim}/bin/maim -s | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png";
      window = "${pkgs.maim}/bin/maim -i \\$(${pkgs.xdotool}/bin/xdotool getactivewindow) '${directory}/${filename}'";
    };
  };
in
{
  config = lib.mkIf helpers.isWM (
    lib.mkMerge [
      (lib.mkIf helpers.isWayland {
        home.packages = [
          pkgs.grim
          pkgs.slurp
          pkgs.jq
        ];
      })
      (lib.mkIf helpers.isX11 {
        home.packages = [
          pkgs.maim
          pkgs.xclip
          pkgs.xdotool
        ];
      })
      {
        home.activation.createScreenshotDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p ${directory}
        '';

        home.file.".local/bin/screenshot-tool" = {
          executable = true;
          text = ''
            #!${pkgs.bash}/bin/bash
            case "$1" in
              "window") ${screenshotCommands.${selectedTool}.window} ;;
              "area") ${screenshotCommands.${selectedTool}.area} ;;
              "full") ${screenshotCommands.${selectedTool}.fullscreen} ;;
              "clip") ${screenshotCommands.${selectedTool}.clipboard} ;;
              *)
                echo "Usage: $0 {window|area|full|clip}"
                echo "  window - Screenshot active window"
                echo "  area   - Screenshot selected area"
                echo "  full   - Screenshot entire screen"
                echo "  clip   - Screenshot area to clipboard"
                ;;
            esac
          '';
        };
      }
    ]
  );
}
