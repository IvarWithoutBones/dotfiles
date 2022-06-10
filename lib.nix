{ nixpkgs
, home-manager
, self
, ...
} @ inputs:

let
  inherit (nixpkgs) lib;
in
rec {
  shell-hook = ''
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

  createSystem = profile:
    { system
    , hostname
    , hardware ? { }
    , modules ? [ ]
    , extraConfig ? { }
    , home-manager ? { }
    , ...
    } @ args:

    let
      _hardware = {
        cpu = "intel";
        gpu = "";
        sound = false;
        touchpad = false;
        battery = false;
        bluetooth = false;
      } // hardware;

      _home-manager = {
        enable = false;
        modules = [ ];
      } // home-manager;

      _modules = modules;
    in
    nixpkgs.lib.nixosSystem rec {
      inherit system;

      specialArgs = {
        inherit (profile) username;
        inherit system;
      } // inputs // _hardware;

      modules = [
        ({
          networking.hostName = hostname;
          system.stateVersion = profile.stateVersion or "";
          nixpkgs.overlays = [ (self.overlays.default or (final: prev: { })) ];
        })
      ]
      ++ _modules
      ++ (profile.modules or [ ])
      ++ [ ((profile.extraConfig or { })) ]
      ++ [ (extraConfig) ]
      ++ lib.optionals (_home-manager.enable or profile.home-manager.enable or false) [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs // args.home-manager;
          home-manager.sharedModules = _home-manager.modules;
          home-manager.users.${profile.username} = {
            home.stateVersion = profile.stateVersion or "";
            imports = _home-manager.modules ++ profile.home-manager.modules or [ ];
          };
        }
      ];
    };
}
