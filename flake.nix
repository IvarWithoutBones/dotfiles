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

      # TODO: move to its own file.
      profiles = {
        laptop = {
          touchpad = true;
          battery = true;
          bluetooth = true;
        };

        ivv = rec {
          username = "ivv";
          stateVersion = "22.11";

          modules = [
            ./modules/hardware.nix
            ./modules/nix.nix
            ./modules/system.nix
            ./modules/steam.nix
            ./modules/graphical.nix
            ./modules/networking.nix
            ({
              networking.extraHosts = ''
                192.168.1.44 pc
                192.168.1.37 laptop
              '';

              users.users.${username}.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzp7kYG8wHjoU1Ski/hABNuT3puOT3icW9DYnweJdR0 ivv@nixos-pc"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEZS38w38lOTIkwTWwnZHFpKIhTKFbj90iDsMjFK7E2G ivv@nixos-laptop"
              ];
            })
          ];
        };

        ivv-darwin = {
          username = "ivv";
          stateVersion = "22.11";

          modules = [
            ./modules/darwin
            ./modules/darwin/yabai.nix
          ];
        };
      };
    in
    rec {
      lib = import ./lib.nix { inherit (inputs) nixpkgs home-manager agenix nix-darwin; inherit self; };
      overlays.default = import ./pkgs/all-packages.nix { inherit (inputs) nix-index-database; };

      darwinConfigurations = {
        ivvs-MacBook-Pro = lib.createSystem profiles.ivv-darwin {
          system = "x86_64-darwin";
          hostname = "darwin-macbook-pro";

          home-manager = {
            enable = true;
            modules = [
              ./home-manager/modules/nix-index.nix
              ./home-manager/modules/mpv.nix
              ./home-manager/modules/zsh.nix
              ./home-manager/modules/nvim.nix
              ./home-manager/packages.nix
            ];
          };
        };
      };

      nixosConfigurations = {
        nixos-pc = lib.createSystem profiles.ivv {
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

          home-manager = {
            enable = true;
            modules = [ ./home-manager/home.nix ];
          };

          modules = [
            ./modules/hardware-config/nixos-pc.nix
          ];
        };

        nixos-laptop = lib.createSystem profiles.ivv rec {
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

          home-manager = {
            enable = true;
            modules = [ ./home-manager/home.nix ];
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

        vm = lib.createSystem profiles.ivv rec {
          system = "x86_64-linux";
          hostname = "vm";

          home-manager = {
            enable = true;
          };

          extraConfig = {
            users.users.ivv.initialPassword = "test";
          };
        };
      };

      # TODO: move these scripts to the overlay

      start-vm = pkgs.writeShellScriptBin "start-nixos-vm" ''
        ${lib.shell-hook}

        nixos-rebuild build-vm --flake ''${DOTFILES_DIR}#vm $@
        ./result/bin/run-vm-vm
      '';

      deploy = pkgs.writeShellScriptBin "deploy-to-cachix" ''
        ${lib.shell-hook}

        NIXOS_SYSTEMS="${toString(builtins.attrNames nixosConfigurations)}"

        rebuild() {
          if [[ "$1" = "vm" ]]; then
            SWITCH="build-vm"
          else
            SWITCH="build"
          fi

          logMessage "Building \"$1\"..."
          nixos-rebuild ''${SWITCH} --flake ''${DOTFILES_DIR}#$1 --use-remote-sudo --print-build-logs

          logMessage "Pushing outputs of \"$1\" to cachix..."
          cachix push ivar-personal ./result

          rm -rf ./result
        }

        for i in ''${NIXOS_SYSTEMS[@]}; do
          rebuild "$i"
        done
      '';
    };
}
