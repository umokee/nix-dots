{
  config,
  pkgs,
  inputs,
  ...
}:
let
  vscode = pkgs.vscode.overrideAttrs (oldAttrs: {
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.makeWrapper ];

    postFixup =
      (oldAttrs.postFixup or "")
      + ''
        wrapProgram $out/bin/code \
          --add-flags "--ozone-platform=wayland" \
          --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer" \
          --add-flags "--enable-gpu-rasterization" \
          --add-flags "--enable-zero-copy"
      '';
  });

  pkgsWithOverlay = import pkgs.path {
    system = pkgs.system;
    overlays = [ inputs.nix-vscode-extensions.overlays.default ];
    config = pkgs.config;
  };

  userSettings = import ./settings.nix {
    inherit config pkgs;
  };
  keybindings = import ./keybindings.nix { };
  extensions = import ./extensions.nix { inherit pkgsWithOverlay; };
in
{
  programs.vscode = {
    enable = true;
    package = vscode;

    profiles.default = {
      inherit userSettings keybindings extensions;
    };
  };
}
