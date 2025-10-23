{ config, pkgs, ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ns-desktop = "sudo nixos-rebuild switch --flake ~/nixos#desktop";
      ns-laptop = "sudo nixos-rebuild switch --flake ~/nixos#laptop";
      ns-server = "sudo nixos-rebuild switch --flake ~/nixos#server";
      hs-desktop = "home-manager switch --flake ~/nixos#desktop -b backup";
      hs-laptop = "home-manager switch --flake ~/nixos#laptop -b backup";
      hs-server = "home-manager switch --flake ~/nixos#server -b backup";
      rebuild-server="nixos-rebuild switch --flake ~/nixos#server --target-host root@185.223.169.86 --build-host localhost";
      nc = "sudo nix-collect-garbage - d";
      hc = "nix-collect-garbage - d";
    };
  };
}
