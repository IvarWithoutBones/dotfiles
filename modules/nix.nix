{
  pkgs,
  ivar-dotfiles,
  ...
}:

let
  inherit (pkgs.stdenvNoCC) hostPlatform;
in
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.latest;
    gc.automatic = true;

    # Pin the nixpkgs channel to the version from this flake.
    nixPath = [ "nixpkgs=${ivar-dotfiles.inputs.nixpkgs}" ];

    registry = {
      dotfiles.flake = ivar-dotfiles.flake; # Add a reference to this flake, for its templates.
      nixpkgs.flake = ivar-dotfiles.inputs.nixpkgs; # Pin the flake registry's nixpkgs to the version from this flake.
    };

    settings = {
      trusted-users = [ "@wheel" ];
      allowed-users = [ "@wheel" ];
      warn-dirty = false; # Gets pretty annoying while working on a flake
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Can causes failures on Darwin, see https://github.com/NixOS/nix/issues/7273.
      auto-optimise-store = !hostPlatform.isDarwin;
    };
  };
}
