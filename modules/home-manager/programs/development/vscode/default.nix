{
  config,
  pkgs,
  inputs,
  stdenv,
  ...
}:
let
  pkgsWithOverlay = import pkgs.path {
    system = stdenv.hostPlatform.system;
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
    package = pkgs.vscode;
    #mutableExtensionsDir = true;

    profiles.default = {
      inherit userSettings keybindings extensions;
    };
  };

  #home.activation.makeVSCodeConfigWritable =
  #  let
  #    configPath = "${config.xdg.configHome}/Code/User/settings.json";
  #  in
  #  {
  #    after = [ "writeBoundary" ];
  #    before = [ ];
  #    data = ''
  #      if [ -L ${configPath} ]; then
  #        install -m 0640 "$(readlink ${configPath})" ${configPath}
  #      fi
  #    '';
  #  };
}
