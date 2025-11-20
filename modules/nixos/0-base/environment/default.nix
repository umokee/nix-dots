{
  lib,
  helpers,
  pkgs,
  ...
}:
let
  wayland = import ./wayland.nix { inherit lib helpers; };
  nvidia = import ./nvidia.nix { inherit lib helpers; };
  intel = import ./intel.nix { inherit lib helpers; };
in
{
  config = {
    environment.sessionVariables = lib.mkMerge [
      wayland
      nvidia
      intel
    ];
  };
}
