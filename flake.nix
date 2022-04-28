{
  description = "My NixOS configuration, using home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
  };

  outputs = inputs @ { self, nixpkgs, home-manager, flake-utils, agenix }: let
    # TODO: add multi platform support
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in rec {
    lib = import ./lib.nix { inherit (inputs) nixpkgs home-manager agenix; };

    # TODO: split up configuration.nix and create proper profiles
    profiles = {
      ivv = {
        username = "ivv";

        modules = [
          ./configuration.nix
          ./modules/hardware.nix
          ./modules/system.nix
        ];
      };
    };

    nixosConfigurations = {
      nixos-pc = lib.createSystem profiles.ivv {
        system = "x86_64-linux";
        hostname = "nixos-pc";

        hardware = {
          cpu = "intel";
          gpu = "nvidia";
        };

        modules = [
          ./modules/hardware-config/nixos-pc.nix
        ];

        homeManager = {
          enable = true;
        };
      };

      nixos-laptop = lib.createSystem profiles.ivv rec {
        system = "x86_64-linux";
        hostname = "nixos-laptop";

        hardware = lib.mkLaptop // {
          gpu = "amd";
          cpu = "amd";
        };

        modules = [
          ./modules/hardware-config/nixos-laptop.nix
        ];

        homeManager = {
          enable = true;
        };

        extraConfig = {
          boot = {
            kernelParams = [ "acpi_backlight=vendor" ]; # Fixes backlight
            extraModulePackages = with pkgs.linuxPackages_latest; [ rtl8821ce ];
          };
        };
      };
    };

    deploy = pkgs.writeShellScriptBin "deploy-to-cachix" ''
      set -e

      logMessage() {
        echo -e "\e[1;32minfo:\e[0m $1"
      }

      rebuild() {
        logMessage "Building \"$1\"..."
        nixos-rebuild build --flake ''${DOTFILES_DIR}#$1 --use-remote-sudo --print-build-logs --option warn-dirty false
        logMessage "Pushing outputs of \"$1\" to cachix..."
        cachix push ivar-personal ./result
        rm -rf ./result
      }

      NIXOS_SYSTEMS="${toString(builtins.attrNames nixosConfigurations)}"
      if [ -z "''${DOTFILES_DIR}" ]; then
        DOTFILES_DIR=$HOME/nix/dotfiles
      fi

      TMPDIR=$(mktemp -d)
      trap "rm -rf ''${TMPDIR}" EXIT
      cd ''${TMPDIR}

      for i in ''${NIXOS_SYSTEMS[@]}; do
        rebuild "$i"
      done
    '';
  };
}
