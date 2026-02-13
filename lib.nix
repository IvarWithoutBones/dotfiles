{
  nixpkgs,
  nix-darwin,
  home-manager,
}@inputs:

let
  inherit (nixpkgs) lib;
in
rec {
  inherit (lib) optional optionals optionalAttrs;

  /*
    Check if a hostPlatform.system is Darwin.

    Example:
       lib.isDarwin "x86_64-darwin"
       => true
  */
  isDarwin = system: lib.hasSuffix "darwin" system;

  /*
    Generate a NixOS/nix-darwin configuration based on a profile, with optional home-manager support.
    A common configuration (referred to as a "profile") is used to share code between flakes.
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
  createSystem =
    profile:
    {
      system,
      modules ? [ ],
      extraConfig ? { },
      home-manager ? { },
      specialArgs ? { },
      commonSpecialArgs ? { },
      ...
    }:

    let
      _username = lib.optionalString _home-manager.enable (
        home-manager.username or profile.home-manager.username
      );
      _modules = modules ++ (profile.modules or [ ]);
      _extraConfig = lib.toList (lib.mergeAttrs (profile.extraConfig or { }) extraConfig);

      _specialArgs = lib.mergeAttrs specialArgs (profile.specialArgs or { });
      _homeManagerSpecialArgs = lib.mergeAttrs (home-manager.specialArgs or { }) (
        profile.home-manager.specialArgs or { }
      );
      _commonSpecialArgs = lib.mergeAttrs commonSpecialArgs (profile.commonSpecialArgs or { });

      _home-manager =
        let
          __extraConfig = lib.toList (
            lib.mergeAttrs (profile.home-manager.extraConfig or { }) (home-manager.extraConfig or { })
          );
        in
        {
          enable =
            if ((profile.home-manager.enable or false) || (home-manager.enable or false)) then true else false;
          modules = (profile.home-manager.modules or [ ]) ++ (home-manager.modules or [ ]) ++ __extraConfig;
        };

      systemFunc = if (isDarwin system) then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;

      homeManagerFunc =
        if (isDarwin system) then
          inputs.home-manager.darwinModules.home-manager
        else
          inputs.home-manager.nixosModules.home-manager;
    in
    systemFunc {
      inherit system;
      specialArgs = {
        inherit system;
      }
      // _commonSpecialArgs
      // _specialArgs;

      modules =
        lib.optionals _home-manager.enable [
          homeManagerFunc
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit system;
            }
            // _commonSpecialArgs
            // _homeManagerSpecialArgs;
            home-manager.sharedModules = _home-manager.modules;
            home-manager.users.${_username}.imports = _home-manager.modules;
          }
        ]
        ++ _modules
        ++ _extraConfig;
    };

  vim = {
    /*
      Import a luafile inside of a vimrc.

      Example:
      lib.vim.mkLuaFile "foo.lua"
      => "lua << EOF dofile(\"foo.lua\") EOF"
    */
    mkLuaFile = file: ''
      lua << EOF
        dofile("${file}")
      EOF
    '';

    /*
      Generate a lua section for a vimrc file.

      Example:
      lib.vim.mkLua "print('hello world')"
      => "lua << EOF print('hello world') EOF"
    */
    mkLua = lua: ''
      lua << EOF
        ${lua}
      EOF
    '';
  };

  # Generate keybindings for readline that apply to all modes: vi-command vi-insert and emacs.
  readlineBindingsAllModes = bindings: ''
    $if mode=vi
      set keymap vi-command
      ${bindings}
      set keymap vi-insert
      ${bindings}
    $else
      ${bindings}
    $endif
  '';
}
