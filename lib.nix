{ nixpkgs
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
     For convenience, attributes for all platforms in nixpkgs are generated.

     Example:
        lib.packagesFromOverlay overlays.default
        => { x86_64-linux = { ... }; x86_64-darwin = { ... }; ... }

        In a flake:
          packages = lib.packagesFromOverlay overlays.default;
  */
  packagesFromOverlay = overlay: {
    inherit (flake-utils.lib.eachSystem lib.platforms.all (system: {
      packages = pkgsWithOverlay system overlay;
    })) packages;
  }.packages;

  /* Generate a NixOS/nix-darwin configuration based on a profile, with optional home-manager support.
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
  createSystem = profile:
    { system
    , modules ? [ ]
    , extraConfig ? { }
    , home-manager ? { }
    , specialArgs ? { }
    , commonSpecialArgs ? { }
    , ...
    }:

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
          home-manager.extraSpecialArgs = { inherit system; } // _commonSpecialArgs // _homeManagerSpecialArgs;
          home-manager.sharedModules = _home-manager.modules;
          home-manager.users.${_username}.imports = _home-manager.modules;
        }
      ]
      ++ _modules
      ++ _extraConfig;
    };

  generators = {
    /* Convert an attribute set to string containing a lua table.

       Example:
          lib.generators.toLua { foo = "bar"; set = { bool = true; list = [ 1 2 3.3 ]; }; }
          => "foo = { \"bar\" }, set = { bool = true, list = { 1, 2, 3.300000 }, },"
    */
    toLua = attributes: (lib.concatMapStringsSep "\n"
      (attrName:
        let
          generate = attrs:
            let
              toValue = value:
                if builtins.isAttrs value then
                  generate value
                else if builtins.isList value then
                  "{ ${lib.concatStringsSep ", " (map toValue value)} }"
                else if builtins.isString value then
                  "\"${builtins.toString value}\""
                else if builtins.isBool value then
                  if value then "true" else "false"
                else if builtins.isInt value || builtins.isFloat value then
                  builtins.toString value
                else abort "generators.toLua: unsupported type ${builtins.typeOf value}";
            in
            if builtins.isAttrs attrs then
              lib.concatStringsSep "\n" (lib.mapAttrsToList
                (attr: attrValue:
                  let
                    # TODO: check for all keywords
                    formattedAttr = if lib.hasInfix "-" attr || attr == "nil" then
                      "[\"${attr}\"]"
                    else
                      attr;

                    value =
                      if builtins.isList attrs || builtins.isAttrs attrValue then
                        "{ ${toValue attrValue} }"
                      else
                        toValue attrValue;
                  in
                  "${formattedAttr} = ${value},")
                attrs)
            else toValue attrs;
        in
        ''
          ${attrName} = {
          ${generate attributes.${attrName}}
          },
        '')
      (builtins.attrNames attributes));
  };

  vim = {
    /* Import a luafile inside of a vimrc.

       Example:
       lib.vim.mkLuaFile "foo.lua"
       => "lua << EOF dofile(\"foo.lua\") EOF"
    */
    mkLuaFile = file: ''
      lua << EOF
        dofile("${file}")
      EOF
    '';

    /* Generate a lua section for a vimrc file.

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

  # Generate keybindings for readline that apply to all modes, e.g. vi-command and vi-insert.
  readlineBindingsAllModes = bindings: lib.concatMapStringsSep "\n"
    (binding: ''
      $if mode=vi
        set keymap vi-command
        ${binding}
        set keymap vi-insert
        ${binding}
      $else
        ${binding}
      $endif
    '')
    bindings;
}
