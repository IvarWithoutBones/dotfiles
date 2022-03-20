{
  description = "My NixOS configuration, using home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = { 
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, flake-utils }: rec {
    lib = import ./lib.nix { inherit (inputs) nixpkgs home-manager; };

    # TODO: split up configuration.nix and create proper profiles
    profiles = {
      ivv = {
        modules = [
          ./configuration.nix
          ./modules/hardware.nix
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

        homeManager = {
          enable = true;
          sm64Rom = /mnt/hdd/roms/n64/baserom.us.z64;
        };
      };

      nixos-laptop = lib.createSystem profiles.ivv rec {
        system = "x86_64-linux";
        hostname = "nixos-laptop";

        hardware = lib.mkLaptop // {
          gpu = "amd";
          cpu = "amd";
        };

        homeManager = {
          enable = true;
          sm64Rom = /home/ivv/misc/games/roms/n64/sm64.z64;
        };

        extraConfig = {
          boot = {
            kernelParams = [ "acpi_backlight=vendor" ]; # Fixes backlight
            extraModulePackages = with nixpkgs.legacyPackages.${system}.linuxPackages_latest; [ rtl8821ce ];
          };
        };
      };
    };
  } // (flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
 in {
    devShell = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        coreutils
        neovim
        bat
        wget
        git
        htop
        unar
        python3
        file
        jq
      ];
    };
  }));
}
