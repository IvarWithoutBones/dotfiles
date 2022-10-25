{
  description = "My NixOS configuration, using home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-index-database.url = "github:mic92/nix-index-database";
    nil-language-server.url = "github:oxalica/nil";

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
    } @ inputs:
    let
      lib = import ./lib.nix {
        inherit nixpkgs home-manager nix-darwin flake-utils;
      };

      profiles = import ./profiles.nix {
        inherit self nixpkgs agenix lib;
      };
    in
    {
      packages = lib.packagesFromOverlay self.overlays.default;
      inherit lib;

      overlays.default = import ./pkgs/all-packages.nix {
        inherit nix-index-database nil-language-server;
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
            ./modules/linux/hardware-config/nixos-pc.nix
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
