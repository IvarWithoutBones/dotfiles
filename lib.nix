{ nixpkgs, home-manager, ... } @ inputs:

rec {
  mkLaptop = {
    touchpad = true;
    battery = true;
    bluetooth = true;
  };

  configFromProfile = profile: {
    nixpkgs.overlays = [];
  } // profile;

  createSystem = profile:
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
        bluetooth = false;
      } // hardware;
    in
    nixpkgs.lib.nixosSystem {
      specialArgs = inputs // hardwareArgs;
      inherit system;

      modules = [({ networking.hostName = hostname; })]
        ++ extraModules
        ++ [( extraConfig )]
        ++ ((configFromProfile profile).modules or [])
        ++ nixpkgs.lib.optionals (homeManager.enable or false) [
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              sm64Rom = null;
            } // homeManager // hardwareArgs;
            home-manager.users.ivv = (import ./home-manager/home.nix) inputs; # TODO: make configurable
          }
        ];
    };
}
