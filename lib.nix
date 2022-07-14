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
    , wayland ? if (hardware.gpu == "amd") then true else false
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
        enable = false;
        modules = [ ];
      } // home-manager;
    in
    nixpkgs.lib.nixosSystem rec {
      inherit system;

      specialArgs = {
        inherit (profile) username;
        inherit system network hostname wayland;
      } // inputs // _hardware;

      modules = [
        ({
          system.stateVersion = profile.stateVersion or "";
          nixpkgs.overlays = [ (self.overlays.default or (final: prev: { })) ];
        })
      ]
      ++ lib.optionals (_home-manager.enable or profile.home-manager.enable or false) [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = _home-manager.modules;
          home-manager.users.${profile.username} = {
            home.stateVersion = profile.stateVersion or "";
            imports = _home-manager.modules ++ profile.home-manager.modules or [ ];
          };

          home-manager.extraSpecialArgs = {
            inherit wayland;
          } // specialArgs // args.home-manager;
        }
      ]
      ++ _modules
      ++ (profile.modules or [ ])
      ++ [ ((profile.extraConfig or { })) ]
      ++ [ (extraConfig) ];
    };
}
