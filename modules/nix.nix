{ config
, pkgs
, lib
, nixpkgs
, username
, ...
}:

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixUnstable;
    registry.nixpkgs.flake = nixpkgs;

    gc.automatic = true;

    settings = rec {
      auto-optimise-store = true;
      warn-dirty = false;

      # Darwin fails to link the package from the binary cache sometimes
      fallback = lib.mkIf pkgs.stdenv.isDarwin true;

      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "@wheel" username ];
      allowed-users = trusted-users;

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
