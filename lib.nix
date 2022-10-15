{ nixpkgs
, home-manager
, nix-darwin
, flake-utils
, ...
} @ inputs:

let
  inherit (nixpkgs) lib;
in
rec {
  inherit (lib) optional optionals optionalAttrs;

  /* Check if a hostPlatform.system is Darwin.

     Example:
        lib.isDarwin "x86_64-darwin"
        => true
  */
  isDarwin = system: lib.hasSuffix "darwin" system;

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
  createSystem = profile:
    { system
    , modules ? [ ]
    , extraConfig ? { }
    , home-manager ? { }
    , specialArgs ? { }
    , commonSpecialArgs ? { }
    , ...
    } @ args:

    let
      _username = lib.optionalString _home-manager.enable (home-manager.username or profile.home-manager.username);
      _modules = modules ++ (profile.modules or [ ]);
      _extraConfig = lib.toList (lib.mergeAttrs (profile.extraConfig or { }) extraConfig);

      _specialArgs = lib.mergeAttrs specialArgs (profile.specialArgs or { });
      _homeManagerSpecialArgs = lib.mergeAttrs (home-manager.specialArgs or { }) (profile.home-manager.specialArgs or { });
      _commonSpecialArgs = lib.mergeAttrs commonSpecialArgs (profile.commonSpecialArgs or { });

      _home-manager = let
        __extraConfig = lib.toList (lib.mergeAttrs (profile.home-manager.extraConfig or { }) (home-manager.extraConfig or { }));
      in {
        enable = if ((profile.home-manager.enable or false) || (home-manager.enable or false)) then true else false;
        modules = (profile.home-manager.modules or [ ]) ++ (home-manager.modules or [ ]) ++ __extraConfig;
      };

      systemFunc =
        if (isDarwin system)
        then nix-darwin.lib.darwinSystem
        else nixpkgs.lib.nixosSystem;

      homeManagerFunc =
        if (isDarwin system)
        then inputs.home-manager.darwinModule
        else inputs.home-manager.nixosModules.home-manager;
    in
    systemFunc {
      inherit system;
      specialArgs = { inherit system; } // _commonSpecialArgs // _specialArgs;

      modules = lib.optionals _home-manager.enable [
        homeManagerFunc
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit system; } // commonSpecialArgs // _homeManagerSpecialArgs;
          home-manager.sharedModules = _home-manager.modules;
          home-manager.users.${_username}.imports = _home-manager.modules;
        }
      ]
      ++ _modules
      ++ _extraConfig;
    };
}
