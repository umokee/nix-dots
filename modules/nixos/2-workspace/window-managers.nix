{
  config,
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

    (lib.mkIf helpers.isDwl {
      environment.systemPackages = with pkgs; [
        wayland
        wayland-protocols
        wlroots_0_19
        wmenu
      ];
      programs.xwayland.enable = true;
    })
    
    (lib.mkIf helpers.isMango {
      programs.mango.enable = true;
    })
  ];
}
