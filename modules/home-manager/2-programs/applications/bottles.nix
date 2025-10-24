{ pkgs, ... }:
{
  home.packages = [
    (pkgs.bottles.overrideAttrs (old: rec {
      version = "3.26";
      src = pkgs.fetchFromGitHub {
        owner = "bottlesdevs";
        repo = "Bottles";
        rev = "3.26";
        hash = ""; # оставь пустым, nix покажет правильный хеш при первой сборке
      };
    }))
  ];
}
