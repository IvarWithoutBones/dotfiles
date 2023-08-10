{ pkgs
, nixpkgs
, username
, ...
}:

let
  trustedAndAllowedUsers = [ "@wheel" username ];
in
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixUnstable;
    gc.automatic = true;

    # Pin the flake registry's nixpkgs to the version from this flake.
    registry.nixpkgs.flake = nixpkgs;

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = trustedAndAllowedUsers;
      allowed-users = trustedAndAllowedUsers;
      warn-dirty = false; # Gets pretty annoying while working on a flake

      # Can causes failures on Darwin, see https://github.com/NixOS/nix/issues/7273.
      # TODO: Maybe add a launchctl service to run `nix store optimise` periodically?
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
