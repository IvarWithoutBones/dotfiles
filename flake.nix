{
  description = "My NixOS/MacOS configurations, using home-manager and nix-darwin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-index-database.url = "github:mic92/nix-index-database";
    nil-language-server.url = "github:oxalica/nil";
    helix.url = "github:helix-editor/helix";
    nixvim.url = "github:pta2002/nixvim";
    sm64ex-practice.url = "github:ivarwithoutbones/sm64ex-practice";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , home-manager
    , flake-utils
    , agenix
    , nix-index-database
    , nil-language-server
    , helix
    , nixvim
    , sm64ex-practice
    }:
    let
      lib = import ./lib.nix {
        inherit nixpkgs home-manager nix-darwin flake-utils;
      };

      profiles = import ./profiles.nix {
        inherit self nixpkgs agenix lib nixvim nix-index-database;
      };
    in
    {
      templates = import ./templates;

      packages = lib.packagesFromOverlay self.overlays.default;
      inherit lib;

      overlays.default = import ./pkgs/all-packages.nix {
        inherit nix-index-database nil-language-server sm64ex-practice helix;
      };

      darwinConfigurations = {
        ivvs-MacBook-Pro = lib.createSystem profiles.ivv-darwin {
          system = "x86_64-darwin";
          hostname = "darwin-macbook-pro";
        };
      };

      nixosConfigurations = {
        nixos-pc = lib.createSystem profiles.ivv-linux {
          system = "x86_64-linux";

          modules = [
            ./modules/linux/nvidia.nix
            ./modules/linux/hardware-config/nixos-pc.nix
          ];

          home-manager.modules = [
            ./home-manager/modules/linux/i3-sway/monitor-layouts/pc.nix
          ];

          commonSpecialArgs = {
            hostname = "nixos-pc";
            wayland = false; # TODO: make this not required, currently there are eval errors when unset

            hardware = {
              sound = true;
              cpu = "intel";
              gpu = "nvidia";
            };

            network = {
              interface = "enp0s31f6";
              address = "192.168.1.44";
            };
          };
        };
      };
    };
}
