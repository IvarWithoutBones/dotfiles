{
  description = "My NixOS configuration, using home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = { 
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, flake-utils }: rec {
    lib = rec {
      inherit (nixpkgs) lib;

      configFromProfile = profile: {
        nixpkgs.overlays = [];
      } // profile;

      nixosConfigFromProfile = profile:
        { system
        , hostname
        , hardware ? {}
        , extraModules ? []
        , extraConfig ? {}
        , homeManager ? {}
        , ... }:

        let
          hardwareArgs = {
            cpu = null;
            gpu = null;
            touchpad = false;
            battery = false;
          } // hardware;
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = inputs // hardwareArgs;
          inherit system;

          modules = [({ networking.hostName = hostname; })]
            ++ extraModules
            ++ [( extraConfig )]
            ++ ((configFromProfile profile).modules or [])
            ++ lib.optionals (homeManager.enable or false) [
              home-manager.nixosModules.home-manager {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = {
                  sm64Rom = null;
                } // hardwareArgs // homeManager;
                home-manager.users.ivv = (import ./home-manager/home.nix) inputs; # TODO: make configurable
              }
            ];
        };
    };

    # TODO: split up configuration.nix and create proper profiles
    testProfile = {
      modules = [
        ./configuration.nix
        ./modules/hardware.nix
      ];
    };

    nixosConfigurations = {
      nixos-pc = lib.nixosConfigFromProfile testProfile {
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

      nixos-laptop = lib.nixosConfigFromProfile testProfile {
        system = "x86_64-linux";
        hostname = "nixos-laptop";

        hardware = {
          gpu = "amd";
          cpu = "amd";
          touchpad = true;
          battery = true;
        };

        homeManager = {
          enable = true;
          sm64Rom = /home/ivv/misc/roms/n64/sm64.z64;
        };

        extraConfig = { config, ... }: {
          boot = {
            kernelParams = [ "acpi_backlight=vendor" ]; # Fixes backlight
            extraModulePackages = with config.boot.kernelPackages; [ rtl8821ce ];
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
      ];
    };
  }));
}
