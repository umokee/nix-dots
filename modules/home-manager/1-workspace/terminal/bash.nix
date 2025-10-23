{ ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ns-desktop = "sudo nixos-rebuild switch --flake ~/nixos#desktop";
      ns-laptop = "sudo nixos-rebuild switch --flake ~/nixos#laptop";
      hs-desktop = "home-manager switch --flake ~/nixos#desktop -b backup";
      hs-laptop = "home-manager switch --flake ~/nixos#laptop -b backup";
      rebuild-server = "cd ~/nixos && \
        STORE_PATH=$(nix build .#nixosConfigurations.server.config.system.build.toplevel --no-link --print-out-paths) && \
        nix-copy-closure --to user@185.223.169.86 $STORE_PATH && \
        ssh user@185.223.169.86 'sudo nix-env -p /nix/var/nix/profiles/system --set $STORE_PATH && sudo $STORE_PATH/bin/switch-to-configuration switch'";
      nc = "sudo nix-collect-garbage - d";
      hc = "nix-collect-garbage - d";
    };
  };
}
