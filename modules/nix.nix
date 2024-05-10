{ pkgs
, nixpkgs
, username
, dotfiles-flake
, ...
}:

let
  trustedAndAllowedUsers = [ "@wheel" username ];
in
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.latest;
    gc.automatic = true;

    registry = {
      dotfiles.flake = dotfiles-flake; # Add a reference to this flake, for its templates.
      nixpkgs.flake = nixpkgs; # Pin the flake registry's nixpkgs to the version from this flake.
    };

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = trustedAndAllowedUsers;
      allowed-users = trustedAndAllowedUsers;
      warn-dirty = false; # Gets pretty annoying while working on a flake

      # Can causes failures on Darwin, see https://github.com/NixOS/nix/issues/7273.
      auto-optimise-store = !pkgs.stdenvNoCC.isDarwin;

      substituters = [
        "https://ivar.cachix.org"
        "https://ivar-personal.cachix.org"
      ];

      trusted-public-keys = [
        "ivar.cachix.org-1:oPUMlRJ2cwtWP3mdNUBe1esfL3+kw5aSWnkseeOn92o="
        "ivar-personal.cachix.org-1:xcf/K8QYcw2XR7Qz8QXNVVWxufSb6Lw5+rkh+CN4cTM="
      ];
    };
  };
}
