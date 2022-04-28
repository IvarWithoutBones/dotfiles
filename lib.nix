{ nixpkgs
, home-manager
, ... } @ inputs:

let
  inherit (nixpkgs) lib;
in
rec {
  shell-functions = ''
    set -e

    logMessage() {
      echo -e "\e[1;32minfo:\e[0m $1"
    }

    if [ -z "''${DOTFILES_DIR}" ]; then
      DOTFILES_DIR=$HOME/nix/dotfiles
    fi

    TMPDIR=$(mktemp -d)
    trap "rm -rf ''${TMPDIR}" EXIT
    cd ''${TMPDIR}
  '';

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
    , home-manager ? {}
    , ... } @ args:

    let
      _hardware = {
        cpu = "intel";
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
        ++ lib.optionals (args.home-manager.enable or false) [
             inputs.home-manager.nixosModules.home-manager {
               home-manager.useGlobalPkgs = true;
               home-manager.useUserPackages = true;

               home-manager.extraSpecialArgs = specialArgs // args.home-manager;
               home-manager.users.${profile.username} = ./home-manager/home.nix; # TODO: make configurable
             }
        ];
    };
}
