{
  description = "NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-colors.url = "github:misterio77/nix-colors";
    mango.url = "github:DreamMaoMao/mango";
    waterfox.url = "github:sammypanda/nixos-waterfox";

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
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      hosts = [
        "desktop"
        "laptop"
        "server"
      ];

      wallpapers = import ./shared/wallpapers.nix;

      commonPkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

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

      mkNixosSystem =
        hostname:
        lib.nixosSystem {
          inherit system;
          specialArgs = mkCommonArgs hostname;
          modules = [
            inputs.disko.nixosModules.disko
            inputs.chaotic.nixosModules.default
            inputs.mango.nixosModules.mango
            { nixpkgs.config.allowUnfree = true; }
            ./modules/nixos
            ./hosts/${hostname}/configuration.nix
          ];
        };

      mkHomeConfiguration =
        hostname:
        home-manager.lib.homeManagerConfiguration {
          pkgs = commonPkgs;
          extraSpecialArgs = mkCommonArgs hostname;
          modules = [
            inputs.nix-colors.homeManagerModules.default
            inputs.mango.hmModules.mango
            { colorScheme = inputs.nix-colors.colorSchemes.ayu-dark; }
            ./modules/home-manager
            ./hosts/${hostname}/home.nix
          ];
        };
    in
    {
      nixosConfigurations = lib.genAttrs hosts mkNixosSystem;
      homeConfigurations = lib.genAttrs hosts mkHomeConfiguration;
    };
}
