{
  config,
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "programs" "obs";
in
{
  config = lib.mkIf enable {
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      package = pkgs.obs-studio.override { cudaSupport = true; };
      plugins = with pkgs.obs-studio-plugins; [
        obs-vkcapture
        obs-move-transition
      ];
    };
  };
}
