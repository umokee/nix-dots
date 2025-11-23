{
  description = "NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-colors.url = "github:misterio77/nix-colors";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    minimalFox = {
      url = "github:Jamir-boop/minimalisticfox";
      flake = false;
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};

      hostsWithHm = [
        "desktop"
        "laptop"
      ];
      hosts = hostsWithHm ++ [ "server" ];

      wallpapers = import ./shared/wallpapers.nix;

      mkCommonArgs =
        hostname:
        let
          conf = import ./shared/config.nix { inherit lib hostname; };
        in
        {
          inherit
            inputs
            wallpapers
            conf
            system
            ;
          helpers = import ./shared/helpers.nix { inherit lib conf; };
        };

      getModules =
        type:
        let
          moduleMap = {
            nixos = [
              inputs.disko.nixosModules.disko
              #inputs.chaotic.nixosModules.default
              { nixpkgs.config.allowUnfree = true; }
              ./modules/nixos
            ];

            home = [
              inputs.nix-colors.homeManagerModules.default
              { colorScheme = inputs.nix-colors.colorSchemes.ayu-dark; }
              ./modules/home-manager
            ];
          };
        in
        moduleMap.${type};

      mkHomeManagerModule = hostname: commonArgs: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "HM";
          extraSpecialArgs = commonArgs;

          users.${commonArgs.conf.username} = {
            imports = (getModules "home") ++ [
              ./hosts/${hostname}/home.nix
            ];

            home.activation.cleanupBackups = home-manager.lib.hm.dag.entryBefore ["checkLinkTargets"] ''
              run find $HOME/.config -maxdepth 2 -name "*.HM" -type f -delete 2>/dev/null || true
            '';
          };
        };
      };

      mkNixosSystem =
        hostname:
        let
          commonArgs = mkCommonArgs hostname;
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = commonArgs;
          modules =
            (getModules "nixos")
            ++ [
              ./hosts/${hostname}/configuration.nix
            ]
            ++ lib.optionals (builtins.elem hostname hostsWithHm) [
              home-manager.nixosModules.home-manager
              (mkHomeManagerModule hostname commonArgs)
            ];
        };
    in
    {
      nixosConfigurations = lib.genAttrs hosts mkNixosSystem;

      devShells.${system} = {
        python = import ./devshells/python.nix { inherit pkgs; };
        csharp = import ./devshells/csharp.nix { inherit pkgs; };
      };
    };
}
