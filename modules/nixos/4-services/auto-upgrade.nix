{
  config,
  lib,
  pkgs,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "services" "auto-upgrade";
in
{
  config = lib.mkIf enable {
    system.autoUpgrade = {
      enable = true;
      flake = "/root/nixos#server";
      flags = [
        "--update-input"
        "nixpkgs"
        "--commit-lock-file"
      ];
      dates = "04:00";
      randomizedDelaySec = "45min";
      allowReboot = false;
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 4d";
    };
  };
}
