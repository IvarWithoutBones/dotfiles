{ nixpkgs
, home-manager
, agenix
, ... } @ inputs:

let
  inherit (nixpkgs) lib;
in
rec {
  mkLaptop = {
    touchpad = true;
    battery = true;
    bluetooth = true;
  };

  createSystem = profile:
    { system
    , hostname
    , hardware ? {}
    , modules ? []
    , extraConfig ? {}
    , homeManager ? {}
    , ... }:

    let
      _hardware = {
        cpu = "";
        gpu = "";
        touchpad = false;
        battery = false;
        bluetooth = false;
      } // hardware;

      _modules = modules;
    in
    nixpkgs.lib.nixosSystem rec {
      inherit system;

      specialArgs = {
        inherit (profile) username;
        inherit system;
      } // inputs // _hardware;

      modules = [({ networking.hostName = hostname; })]
        ++ _modules
        ++ (profile.modules or [])
        ++ [(( profile.extraConfig or {} // extraConfig ))] # TODO: this line is causing errors when profile.extraConfig is defined as a function
        ++ lib.optionals (homeManager.enable or false) [
             home-manager.nixosModules.home-manager {
               home-manager.useGlobalPkgs = true;
               home-manager.useUserPackages = true;

               home-manager.extraSpecialArgs = specialArgs // {
                 sm64Rom = null;
               } // homeManager;

               home-manager.users.${profile.username} = ./home-manager/home.nix; # TODO: make configurable
             }
        ];
    };
}
