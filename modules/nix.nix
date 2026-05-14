{
  lib,
  pkgs,
  ivar-dotfiles,
  ...
}:

let
  substituters = {
    # Created in `modules/linux/nix-ssh-serve.nix`.
    # To temporarily enable one of these, pass `--extra-substituters 'ssh://nix-ssh@foo?priority=100'` to `nix build` and friends.
    "ssh://nix-ssh@dco-ivar-pc" = "nixos-pc-1:b6bErWvNvqT/5S8n7Yz2SMYKgP/3Ipg/cpf5nbGbqZo=";
    "ssh://nix-ssh@dco-ivar-macbook" = "nixos-macbook-1:7yI4aZ1e9o2JzzjKlJsha9SlSSJEDTuxH1OaC7VtxZo=";
    "ssh://nix-ssh@dco-ivar-framework" =
      "nixos-framework-1:Y5qUd6Oym1fqwFAO83Y6cM5mPHfv3UKmqtf5MqyXv0w=";
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

      # Allow using local machines as binary caches.
      extra-trusted-public-keys = lib.attrValues substituters;
      extra-trusted-substituters = lib.attrNames substituters;

      extra-experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Can causes failures on Darwin, see https://github.com/NixOS/nix/issues/7273.
      auto-optimise-store = !pkgs.stdenv.hostPlatform.isDarwin;

      # When possible, make builders use their own substituters instead of the client's store.
      builders-use-substitutes = true;

      # Build derivations locally if we can't reach a subsituter.
      fallback = true;

      # Gets pretty annoying while working on a flake.
      warn-dirty = false;
    };
  };
}
