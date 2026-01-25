{
  description = "My NixOS/MacOS configurations, using home-manager and nix-darwin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sm64ex-practice.url = "github:ivarwithoutbones/sm64ex-practice";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixvim = {
      url = "github:pta2002/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , home-manager
    , flake-utils
    , nix-index-database
    , nixvim
    , sm64ex-practice
    , nixos-hardware
    }:
    let
      lib = import ./lib.nix {
        inherit nixpkgs nix-darwin home-manager;
      };

      profiles = import ./profiles.nix {
        inherit self nixpkgs lib nixvim nix-index-database;
      };
    in
    {
      inherit lib;
      templates = import ./templates;
      overlays.default = import ./pkgs/all-packages.nix;

      darwinConfigurations = {
        ivvs-MacBook-Pro = lib.createSystem profiles.darwin {
          system = "x86_64-darwin";

          modules = [
            ({ ... }: {
              users.users."ivv" = {
                isHidden = false;
                home = "/Users/ivv";
              };

              system = {
                primaryUser = "ivv";
                stateVersion = 5;
              };
            })
          ];

          home-manager.modules = [
            ({ ... }: {
              programs.alacritty.settings.font.size = 15.5;
              home.stateVersion = "21.11";
            })
          ];
        };
      };

      nixosConfigurations = {
        nixos-pc = lib.createSystem profiles.linux {
          system = "x86_64-linux";

          modules = [
            ./modules/linux/hardware/config/nixos-pc.nix
            ./modules/linux/hardware/cpu/intel.nix
            ./modules/linux/hardware/gpu/nvidia.nix
            ./modules/linux/hardware/touchpad.nix
            ./modules/linux/steam.nix
            ./modules/linux/jellyfin.nix
            ./modules/linux/sunshine.nix

            ({ pkgs, ... }: {
              users.users."ivv" = {
                isNormalUser = true;
                extraGroups = [ "wheel" "plugdev" "dialout" ];
                shell = pkgs.zsh;
              };

              networking = {
                hostName = "nixos-pc";
                interfaces.enp0s31f6.ipv4.addresses = [{
                  address = "192.168.1.44";
                  prefixLength = 28;
                }];
              };

              system.stateVersion = "21.11";
            })
          ];

          home-manager.modules = [
            ./home-manager/modules/games.nix
            ./home-manager/modules/linux/i3-sway/nvidia.nix
            ./home-manager/modules/linux/i3-sway/i3.nix
            ./home-manager/modules/linux/i3-sway/sway.nix

            ({ system, ... }: {
              home = {
                packages = [ sm64ex-practice.packages.${system}.default ];
                stateVersion = "21.11";
              };
            })
          ];
        };

        nixos-macbook = lib.createSystem profiles.linux {
          system = "x86_64-linux";

          modules = [
            nixos-hardware.nixosModules.apple-t2
            ./modules/linux/hardware/config/nixos-macbook.nix
            ./modules/linux/hardware/cpu/intel.nix
            ./modules/linux/hardware/touchpad.nix
            ./modules/linux/hardware/bluetooth.nix

            ({ pkgs, lib, ... }: {
              # Use MacOS's boot partition.
              boot.loader.efi.efiSysMountPoint = "/boot";

              # Use Apple's Bluetooth/Wifi firmware. Option comes from nixos-hardware.
              hardware.apple-t2.firmware.enable = true;

              # Enable the nixos-t2 binary cache.
              nix.settings =
                let
                  substituters = [ "https://cache.soopy.moe" ];
                in
                {
                  inherit substituters;
                  trusted-substituters = substituters;
                  trusted-public-keys = [ "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo=" ];
                };

              users.users."ivv" = {
                isNormalUser = true;
                extraGroups = [ "wheel" "plugdev" "dialout" ];
                shell = pkgs.zsh;
              };

              networking.hostName = "nixos-macbook";
              system.stateVersion = "25.11";
            })
          ];

          home-manager.modules = [
            ./home-manager/modules/linux/i3-sway/sway.nix
            ./home-manager/modules/linux/blueman-applet.nix

            ({ ... }: {
              home.stateVersion = "25.11";
            })
          ];
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
        config.allowUnfree = true;
      };
    in
    {
      # Every derivation defined in ./pkgs/all-packages.nix
      packages = nixpkgs.lib.filterAttrs (_name: value: nixpkgs.lib.isDerivation value) (self.overlays.default pkgs pkgs);
    });
}
