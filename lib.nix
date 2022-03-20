{ nixpkgs, home-manager, ... } @ inputs:

let
  inherit (nixpkgs) lib;
in
rec {
  mkLaptop = {
    touchpad = true;
    battery = true;
    bluetooth = true;
  };

  configFromProfile = profile: {
    extraConfig = {
      nixpkgs.overlays = [];
    };
  } // profile;

  createSystem = _profile:
    { system
    , hostname
    , hardware ? {}
    , extraModules ? []
    , extraConfig ? {}
    , homeManager ? {}
    , ... }:

    let
      profile = configFromProfile _profile;

      _hardware = {
        cpu = "";
        gpu = "";
        touchpad = false;
        battery = false;
        bluetooth = false;
      } // hardware;
    in
    nixpkgs.lib.nixosSystem rec {
      specialArgs = inputs // _hardware;
      inherit system;

      modules = [({ networking.hostName = hostname; })]
        ++ extraModules
        ++ (profile.modules or [])
        ++ [(( profile.extraConfig or {} // extraConfig ))] # TODO: this line is causing errors when profile.extraConfig is defined as a function
        ++ lib.optionals (homeManager.enable or false) [
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              sm64Rom = null;
            } // homeManager // _hardware;
            home-manager.users.ivv = (import ./home-manager/home.nix) inputs; # TODO: make configurable
          }
        ];
    };
}
