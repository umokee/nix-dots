{
  config,
  pkgs,
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "workspace" "themes";

  colorDetectionScript = pkgs.writeScript "papirus-color-finder.py" ''
    #!/usr/bin/env python3
    import sys

    PAPIRUS_COLORS = {
        'adwaita': '#93c0ea',
        'black': '#4f4f4f',
        'blue': '#5294e2',
        'bluegrey': '#607d8b',
        'breeze': '#57b8ec',
        'brown': '#ae8e6c',
        'carmine': '#a30002',
        'cyan': '#00bcd4',
        'darkcyan': '#45abb7',
        'deeporange': '#eb6637',
        'green': '#87b158',
        'grey': '#8e8e8e',
        'indigo': '#5c6bc0',
        'magenta': '#ca71df',
        'nordic': '#81a1c1',
        'orange': '#ee923a',
        'palebrown': '#d1bfae',
        'paleorange': '#eeca8f',
        'pink': '#f06292',
        'red': '#e25252',
        'teal': '#16a085',
        'violet': '#7e57c2',
        'white': '#e4e4e4',
        'yaru': '#676767',
        'yellow': '#f9bd30',
    }

    def hex_to_rgb(hex_color):
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

    def color_distance(rgb1, rgb2):
        return sum((a - b) ** 2 for a, b in zip(rgb1, rgb2)) ** 0.5

    def find_closest_papirus_color(hex_input):
        rgb_input = hex_to_rgb(hex_input)
        min_distance = float('inf')
        closest_name = None

        for name, hex_val in PAPIRUS_COLORS.items():
            distance = color_distance(rgb_input, hex_to_rgb(hex_val))
            if distance < min_distance:
                min_distance = distance
                closest_name = name 
        return closest_name

    if __name__ == "__main__":
        if len(sys.argv) != 2:
            print("Использование: python3 papirus_color_finder.py '#94EBEB'")
            sys.exit(1)

        input_hex = sys.argv[1] if sys.argv[1].startswith('#') else '#' + sys.argv[1]
        name = find_closest_papirus_color(input_hex)
        print(name)
  '';
in
{
  config = lib.mkIf enable {
    home.packages = with pkgs; [
      papirus-folders
    ];

    home.activation = {
      papirusColorDetector = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        export PATH="${
          lib.makeBinPath (
            with pkgs;
            [
              gawk
              gtk3
            ]
          )
        }:$PATH"

        requested_hex="${config.colorScheme.palette.base0D or "5294e2"}"
        papirus_color=$(${pkgs.python3}/bin/python3 ${colorDetectionScript} "$requested_hex")
        ${pkgs.papirus-folders}/bin/papirus-folders -C "$papirus_color" --theme "Papirus-Dark"
        ${pkgs.gtk3}/bin/gtk-update-icon-cache -f "$HOME/.local/share/icons" 2>/dev/null || true
      '';
    };
  };
}
