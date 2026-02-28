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
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nixos-hardware,
      sm64ex-practice,
      ...
    }@inputs:
    let
      lib = import ./lib.nix {
        inherit nixpkgs nix-darwin home-manager;
      };

      profiles = import ./profiles.nix {
        inherit
          self
          inputs
          ;
      };

      forEachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
              config.allowUnfree = true;
            }
          )
        );
    in
    {
      inherit lib;
      templates = import ./templates;
      overlays.default = import ./pkgs/all-packages.nix;

      # All the packages defined in `self.overlays.default`.
      packages = forEachSystem (
        final:
        nixpkgs.lib.filterAttrs (_name: value: nixpkgs.lib.isDerivation value) (
          self.overlays.default final (
            import nixpkgs {
              inherit (final.stdenv.hostPlatform) system;
              config.allowUnfree = true;
            }
          )
        )
      );

      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            treefmt
            nixfmt
            shfmt
            taplo
            stylua
          ];
        };
      });

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
            ./modules/linux/audiobookshelf.nix
            ./modules/linux/sunshine.nix
            ./modules/linux/desktop/xserver.nix

            (
              { ... }:
              {
                # Extra directories that transmission has access to.
                systemd.services.transmission.serviceConfig.BindPaths = [
                  "/mnt/hdd/downloads"
                  "/mnt/ssd1/downloads"
                ];

                systemd.network.networks."10-enp0s31f6" = {
                  matchConfig.Name = "enp0s31f6";
                  networkConfig.DHCP = "yes";
                  address = [ "192.168.1.44/24" ];
                };

                networking.hostName = "nixos-pc";
                system.stateVersion = "21.11";
              }
            )
          ];

          home-manager.modules = [
            ./home-manager/modules/games.nix
            ./home-manager/modules/linux/i3-sway/nvidia.nix
            ./home-manager/modules/linux/i3-sway/i3.nix
            ./home-manager/modules/linux/i3-sway/sway.nix

            (
              { system, ... }:
              {
                home = {
                  packages = [ sm64ex-practice.packages.${system}.default ];
                  stateVersion = "21.11";
                };
              }
            )
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

            (
              { ... }:
              {
                # Use MacOS's boot partition.
                boot.loader.efi.efiSysMountPoint = "/boot";

                # Use Apple's Bluetooth/Wifi firmware. Option comes from nixos-hardware.
                hardware.apple-t2.firmware.enable = true;

                networking = {
                  hostName = "nixos-macbook";
                  wireless.iwd.enable = true;
                };

                system.stateVersion = "25.11";
              }
            )
          ];

          home-manager.modules = [
            ./home-manager/modules/linux/i3-sway/sway.nix
            ./home-manager/modules/linux/blueman-applet.nix

            (
              { ... }:
              {
                home.stateVersion = "25.11";
              }
            )
          ];
        };
      };

      darwinConfigurations = {
        ivvs-MacBook-Pro = lib.createSystem profiles.darwin {
          system = "x86_64-darwin";

          modules = [
            (
              { ... }:
              {
                users.users."ivv" = {
                  isHidden = false;
                  home = "/Users/ivv";
                };

                system = {
                  primaryUser = "ivv";
                  stateVersion = 5;
                };
              }
            )
          ];

          home-manager.modules = [
            (
              { ... }:
              {
                programs.alacritty.settings.font.size = 15.5;
                home.stateVersion = "21.11";
              }
            )
          ];
        };
      };
    };
}
