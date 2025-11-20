{ ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ns-desktop = "sudo nixos-rebuild switch --flake ~/nix-dots#desktop";
      ns-laptop = "sudo nixos-rebuild switch --flake ~/nix-dots#laptop";
      ns-server = "nixos-rebuild switch --flake ~/nix-dots#server --target-host user@185.223.169.86 --sudo";
      nc = "sudo nix-collect-garbage -d";
      hc = "nix-collect-garbage -d";
      gc = "git add . && git commit -m";
      gp = "git push -u origin main";
    };
  };
}
