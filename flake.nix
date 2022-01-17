{
  # TODO: add system specific configurations to importable modules when it makes sense, so it's more portable. (intel/amd, nvidia, etc)

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
        { system, extraModules ? [], extraConfig ? {}, ... }:
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = extraModules
              ++ [( extraConfig )]
              ++ (configFromProfile profile).modules;
          };
    };

    # TODO: create a seperate file for this, we also want to optionally integrate home-manager. preferably from nixos module
    # This also means we have to properly seperate everything into their own module, so that each profile can import whatever they choose.
    testProfile = {
      modules = [
        ./configuration.nix
      ];
    };

    nixosConfigurations = {
      nixos-pc = lib.nixosConfigFromProfile testProfile {
        system = "x86_64-linux";

        # TODO: remove the { ... } part when nvidia shit is factored out.
        extraConfig = { config, ...}: {
          networking.hostName = "nixos-pc";

          services.xserver = {
            videoDrivers = [ "nvidia" ];
            screenSection = '' # Fixes screentearing on nvidia GPUs
              Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
            '';
          };

          hardware = {
            nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
            cpu.intel.updateMicrocode = true;
          };
        };

        extraModules = [
          home-manager.nixosModules.home-manager {
            home-manager.extraSpecialArgs = {
              hasBattery = false;
              sm64Rom = /mnt/hdd/roms/n64/baserom.us.z64;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ivv = (import ./home-manager/home.nix) inputs;
          }
        ];
      };

      nixos-laptop = lib.nixosConfigFromProfile testProfile {
        system = "x86_64-linux";

        extraConfig = { config, ... }: {
          networking.hostName = "nixos-laptop";

          boot = {
            kernelParams = [ "acpi_backlight=vendor" ]; # Fixes backlight
            extraModulePackages = with config.boot.kernelPackages; [ rtl8821ce ];
          };

          services.xserver = {
            videoDrivers = [ "amdgpu" ];
            libinput = {
              enable = true;
              touchpad = {
                tapping = false;
                naturalScrolling = true;
                accelProfile = "flat";
              };
            };
          };
          hardware.cpu.amd.updateMicrocode = true;
        };

        extraModules = [
          home-manager.nixosModules.home-manager {
            home-manager.extraSpecialArgs = {
              hasBattery = true;
              sm64Rom = /home/ivv/misc/roms/n64/sm64.z64;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ivv = (import ./home-manager/home.nix) inputs;
          }
        ];
      };
    };
  } // (flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
 in {
    devShell = pkgs.mkShell {
      buildInputs = with pkgs; [
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
