{ nixpkgs, home-manager, ... } @ inputs:

rec {
  configFromProfile = profile: {
    nixpkgs.overlays = [];
  } // profile;

  nixosConfigFromProfile = profile:
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
            } // hardwareArgs // homeManager;
            home-manager.users.ivv = (import ./home-manager/home.nix) inputs; # TODO: make configurable
          }
        ];
    };
}
