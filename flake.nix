{
  description = "My NixOS configuration, using home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:mic92/nix-index-database";
  };

  outputs = inputs @ { self, nixpkgs, nix-darwin, home-manager, flake-utils, agenix, nix-index-database }:
    let
      pkgs = flake-utils.lib.eachDefaultSystem (system: nixpkgs.legacyPackages.${system});
      profiles = import ./profiles.nix;
    in
    rec {
      lib = import ./lib.nix { inherit (inputs) nixpkgs home-manager agenix nix-darwin; inherit self; };
      overlays.default = import ./pkgs/all-packages.nix { inherit (inputs) nix-index-database; };

      darwinConfigurations = {
        ivvs-MacBook-Pro = lib.createSystem profiles.ivv-darwin {
          system = "x86_64-darwin";
          hostname = "darwin-macbook-pro";
        };
      };

      nixosConfigurations = {
        nixos-pc = lib.createSystem profiles.ivv-linux {
          system = "x86_64-linux";
          hostname = "nixos-pc";

          hardware = {
            sound = true;
            cpu = "intel";
            gpu = "nvidia";
          };

          network = {
            interface = "enp0s31f6";
            address = "192.168.1.44";
          };

          modules = [
            ./modules/hardware-config/nixos-pc.nix
          ];
        };

        nixos-laptop = lib.createSystem profiles.ivv-linux rec {
          system = "x86_64-linux";
          hostname = "nixos-laptop";

          hardware = profiles.laptop // {
            sound = true;
            gpu = "amd";
            cpu = "amd";
          };

          network = {
            interface = "wlp1s0";
            address = "192.168.1.37";
          };

          modules = [
            ./modules/hardware-config/nixos-laptop.nix
          ];

          extraConfig = { config, ... }: {
            boot = {
              kernelParams = [ "acpi_backlight=vendor" ]; # Fixes backlight
              extraModulePackages = with config.boot.kernelPackages; [ rtl8821ce ];
            };
          };
        };
      };
    };
}
