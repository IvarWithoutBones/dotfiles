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

  outputs = { self, nixpkgs, home-manager, flake-utils }: let
    notmuch-overlay = final: prev: {
      notmuch = prev.notmuch.overrideAttrs (attrs: {
        doCheck = false;
      });
    };
  in {
    nixosConfigurations.nixos-laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ({ pkgs, config, ... }: {
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
        })
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ivv = import ./home-manager/home.nix;
        }
      ];
    };
    nixosConfigurations.nixos-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ({ pkgs, config, ... }: {
          # TODO: remove this
          nixpkgs.overlays = [ notmuch-overlay ];

          networking.hostName = "nixos-pc";
          services.xserver = {
            videoDrivers = [ "nvidia" ];
            screenSection = '' # Fixes screentearing on nvidia GPUs
              Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
          '';
          };
          hardware = {
            # TODO: currently `beta` fails to compile, switch this back as soon as it doesn't
            nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
            cpu.intel.updateMicrocode = true;
          };
        })
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ivv = import ./home-manager/home.nix;
        }
      ];
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
