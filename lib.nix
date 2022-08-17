{ nixpkgs
, home-manager
, nix-darwin
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
        enable = false;
        modules = [ ];
      } // (profile.home-manager or { }) // home-manager;

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
      ++ lib.optionals (_home-manager.enable or false) [
        homeManagerFunc
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
          } // specialArgs // _home-manager;
        }
      ]
      ++ _modules
      ++ (profile.modules or [ ])
      ++ [ ((profile.extraConfig or { })) ]
      ++ [ (extraConfig) ];
    };
}
