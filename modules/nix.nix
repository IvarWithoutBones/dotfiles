{
  lib,
  pkgs,
  ivar-dotfiles,
  ...
}:

let
  substituters = {
    # Created in `modules/linux/nix-ssh-serve.nix`.
    "ssh://nix-ssh@dco-ivar-pc" = "nixos-pc-1:b6bErWvNvqT/5S8n7Yz2SMYKgP/3Ipg/cpf5nbGbqZo=";
    "ssh://nix-ssh@dco-ivar-laptop" = "nixos-macbook-1:7yI4aZ1e9o2JzzjKlJsha9SlSSJEDTuxH1OaC7VtxZo=";
  };
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
      extra-trusted-users = [ "@wheel" ];
      extra-allowed-users = [ "@wheel" ];
      warn-dirty = false; # Gets pretty annoying while working on a flake.
      fallback = true; # Build derivations locally if we can't reach a subsituter.
      auto-optimise-store = !pkgs.stdenv.hostPlatform.isDarwin; # Can causes failures on Darwin, see https://github.com/NixOS/nix/issues/7273.

      extra-experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Allow using local machines as binary caches.
      extra-trusted-public-keys = lib.attrValues substituters;
      extra-trusted-substituters = lib.attrNames substituters;
    };
  };
}
