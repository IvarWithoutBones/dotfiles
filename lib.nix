{ nixpkgs
, home-manager
, nix-darwin
, flake-utils
, self
, ...
} @ inputs:

let
  inherit (nixpkgs) lib;
in
rec {
  /* Generate a list of packages for the specified system with an overlay applied.

     Example:
        lib.pkgsWithOverlay "x86_64-linux" overlays.default
        => { ... } # The resulting package set
  */
  pkgsWithOverlay = system: overlay: import nixpkgs {
    overlays = [ overlay ];
    inherit system;
  };

  /* Generate a list of packages with an overlay applied, to be used as a flake output.
     For convienience, attributes for all platforms in nixpkgs are generated.

     Example:
        lib.packagesFromOverlay overlays.default
        => { x86_64-linux = { ... }; x86_64-darwin = { ... }; ... }

        In a flake:
          packages = lib.packagesFromOverlay overlays.default;
  */
  packagesFromOverlay = overlay: {
    inherit (flake-utils.lib.eachSystem lib.platforms.all (system: rec {
      packages = pkgsWithOverlay system overlay;
    })) packages;
  }.packages;

  /* Generate a NixOS/nix-darwin configuration based on a profile, with optional home-manager support.
     A common configuration (refered to as a "profile") is used to share code between flakes.
     This is used to avoid code repetition for flakes that configure multiple machines.

     Example:
       lib.createSystem
       {
         # The profile, usually defined elsewhere
         modules = [ ./modules/graphical.nix ];
         home-manager = {
           enable = true;
           modules = [ ./home-manager/modules/zsh.nix ];
         };
       }
       # System definition, usually configured in the flake output
       { system = "x86_64-linux"; }
       => {
            _module = { ... };
            config = { ... };
            extendModules = «lambda»;
            extraArgs = { ... };
            options = { ... };
            pkgs = { ... };
            type = { ... };
          }

       In a flake:
         profile = { home-manager = { enable = true; modules = [ ./home-manager/modules/zsh.nix ]; }; };
         nixosConfigurations.nixos-machine = lib.createSystem profile { system = "x86_64-linux"; };
         darwinConfigurations.darwin-machine = lib.createSystem profile { system = "x86_64-darwin"; };
  */
  # TODO: dont hardcode arguments, instead pass anything unknown to this function as specialArgs
  createSystem = profile:
    { system
    , hostname ? null
    , hardware ? { }
    , wayland ? if (hardware.gpu or "" == "amd") then true else false
    , network ? { }
    , modules ? [ ]
    , extraConfig ? { }
    , home-manager ? { }
    } @ args:

    let
      _modules = modules;

      _hardware = {
        cpu = "intel";
        gpu = "";
        sound = false;
        touchpad = false;
        battery = false;
        bluetooth = false;
      } // hardware;

      _home-manager = {
        enable = if ((profile.home-manager.enable or false) || (home-manager.enable or false)) then true else false;
        modules = [ ] ++ (profile.home-manager.modules or [ ]) ++ (home-manager.modules or [ ]);
      };

      isDarwin = if (system == "x86_64-darwin" || system == "aarch64-darwin") then true else false;
      systemFunc = if isDarwin then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
      homeManagerFunc = if isDarwin then inputs.home-manager.darwinModule else inputs.home-manager.nixosModules.home-manager;
    in
    systemFunc rec {
      inherit system;

      specialArgs = {
        inherit (profile) username;
        inherit system network hostname wayland;
      } // inputs // _hardware;

      modules = [
        ({
          nixpkgs.overlays = [ (self.overlays.default or (final: prev: { })) ];
        } // lib.optionalAttrs (!isDarwin) {
          # For some reason system.stateVersion doesnt seem to work with nix-darwin
          system.stateVersion = profile.stateVersion or "";
        })
      ]
      ++ lib.optionals _home-manager.enable [
        homeManagerFunc
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = _home-manager.modules;
          home-manager.users.${profile.username} = {
            home.stateVersion = profile.stateVersion or "";
            imports = _home-manager.modules;
          };

          home-manager.extraSpecialArgs = {
            inherit wayland;
          } // specialArgs // _home-manager;
        }
      ]
      ++ _modules
      ++ (profile.modules or [ ])
      ++ [ ((profile.extraConfig or { })) ]
      ++ [ (extraConfig) ];
    };
}
