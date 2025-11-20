{
  lib,
  helpers,
  pkgs,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf helpers.isHyprland {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };
    })

  ];
}
