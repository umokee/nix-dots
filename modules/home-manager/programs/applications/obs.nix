{
  lib,
  pkgs,
  helpers,
  ...
}:
{
  config = lib.mkMerge [
    {
      programs.obs-studio = {
        enable = true;

        plugins = with pkgs.obs-studio-plugins; [
          obs-pipewire-audio-capture
          obs-gstreamer
          obs-websocket
          obs-move-transition
          obs-backgroundremoval
          obs-shaderfilter
          obs-vkcapture
          obs-source-record
          obs-vertical-canvas
          input-overlay
          advanced-scene-switcher
        ];
      };
    }

    (lib.mkIf helpers.isWayland {
      programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
        wlrobs
      ];
    })

    (lib.mkIf helpers.hasNvidia {
      programs.obs-studio = {
        package = pkgs.obs-studio.override {
          cudaSupport = true;
        };
      };
    })

    (lib.mkIf (!helpers.hasNvidia) {
      programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
        obs-vaapi
      ];
    })
  ];
}
