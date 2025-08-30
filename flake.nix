{
  description = "My NixOS/MacOS configurations, using home-manager and nix-darwin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sm64ex-practice.url = "github:ivarwithoutbones/sm64ex-practice";

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

      overlays.default = import ./pkgs/all-packages.nix {
        inherit sm64ex-practice;
      };

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
            ./home-manager/modules/linux/i3-sway/nvidia.nix
            ./home-manager/modules/linux/i3-sway/monitor-layouts/pc.nix
            ({ ... }: {
              home.stateVersion = "21.11";
            })
          ];

          commonSpecialArgs = {
            wayland = false; # TODO: make this not required, currently there are eval errors when unset
          };
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
