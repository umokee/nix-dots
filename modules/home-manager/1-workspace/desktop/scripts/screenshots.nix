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

  screenshotCommands = {
    grim = {
      fullscreen = "grim - | tee '${directory}/$(date +%Y-%m-%d_%H-%M-%S).png' | wl-copy -t image/png";
      area = "grim -g \"$(slurp)\" - | tee '${directory}/$(date +%Y-%m-%d_%H-%M-%S).png' | wl-copy -t image/png";
      clipboard = "grim -g \"$(slurp)\" - | wl-copy -t image/png";
      window = "hyprctl -j activewindow | jq -r '\"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"' | grim -g - - | tee '${directory}/$(date +%Y-%m-%d_%H-%M-%S).png' | wl-copy -t image/png";
    };

    maim = {
      fullscreen = "maim '${directory}/$(date +%Y-%m-%d_%H-%M-%S).png'";
      area = "maim -s '${directory}/$(date +%Y-%m-%d_%H-%M-%S).png'";
      clipboard = "maim -s | xclip -selection clipboard -t image/png";
      window = "maim -i $(xdotool getactivewindow) '${directory}/$(date +%Y-%m-%d_%H-%M-%S).png'";
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
        ];
      })
      (lib.mkIf helpers.isX11 {
        home.packages = [
          pkgs.maim
          pkgs.xclip
        ];
      })
      {
        home.activation.createScreenshotDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p ${directory}
        '';

        home.file.".local/bin/screenshot-area" = {
          executable = true;
          text = ''
            #!${pkgs.bash}/bin/bash
            ${screenshotCommands.${selectedTool}.area}
          '';
        };

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
