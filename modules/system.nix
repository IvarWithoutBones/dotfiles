{ config
, pkgs
, agenix
, system
, username
, ...
}:

{
  imports = [ agenix.nixosModule ];

  age.secrets = {
    cachix-config = {
      name = "cachix-config";
      file = ../secrets/cachix-config.age;
      owner = username;
    };
  };

  nix = {
    package = pkgs.nixUnstable;

    settings = rec {
      auto-optimise-store = true;
      warn-dirty = false;

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

  environment = {
    systemPackages = with pkgs; [
      agenix.defaultPackage.${system}

      (pkgs.runCommand "cachix-configured" {
        nativeBuildInputs = [ makeWrapper ];
      } ''
        mkdir -p $out/bin

        makeWrapper ${pkgs.cachix}/bin/cachix $out/bin/cachix \
          --add-flags "--config ${config.age.secrets.cachix-config.path}"
      '')
    ];
  };
}
