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

            DIR="${directory}"

            get_next_number() {
              local i=1
              while [[ -e "$DIR/screenshot-$i.png" ]]; do
                ((i++))
              done
              echo "$i"
            }

            NUM=$(get_next_number)
            FILE="$DIR/screenshot-$NUM.png"

            case "$1" in
              "window")
                if [[ "${selectedTool}" == "grim" ]]; then
                  ${pkgs.hyprland}/bin/hyprctl -j activewindow | \
                    ${pkgs.jq}/bin/jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | \
                    ${pkgs.grim}/bin/grim -g - "$FILE"
                  ${pkgs.wl-clipboard}/bin/wl-copy < "$FILE"
                else
                  ${pkgs.maim}/bin/maim -i $(${pkgs.xdotool}/bin/xdotool getactivewindow) "$FILE"
                  ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png < "$FILE"
                fi
                echo "Saved: $FILE"
                ;;
              
              "area")
                if [[ "${selectedTool}" == "grim" ]]; then
                  ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$FILE"
                  ${pkgs.wl-clipboard}/bin/wl-copy < "$FILE"
                else
                  ${pkgs.maim}/bin/maim -s "$FILE"
                  ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png < "$FILE"
                fi
                echo "Saved: $FILE"
                ;;
              
              "full")
                if [[ "${selectedTool}" == "grim" ]]; then
                  ${pkgs.grim}/bin/grim "$FILE"
                  ${pkgs.wl-clipboard}/bin/wl-copy < "$FILE"
                else
                  ${pkgs.maim}/bin/maim "$FILE"
                  ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png < "$FILE"
                fi
                echo "Saved: $FILE"
                ;;
              
              "clip")
                if [[ "${selectedTool}" == "grim" ]]; then
                  ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | \
                    ${pkgs.wl-clipboard}/bin/wl-copy -t image/png
                else
                  ${pkgs.maim}/bin/maim -s | \
                    ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png
                fi
                echo "Copied to clipboard"
                ;;
              
              *)
                echo "Usage: $0 {window|area|full|clip}"
                echo "  window - Screenshot active window"
                echo "  area   - Screenshot selected area"
                echo "  full   - Screenshot entire screen"
                echo "  clip   - Screenshot area to clipboard only"
                ;;
            esac
          '';
        };
      }
    ]
  );
}
