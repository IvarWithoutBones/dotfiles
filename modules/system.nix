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

    sm64 = {
      name = "sm64-us.z64";
      file = ../secrets/sm64.age;
      # We want to read this from the sandbox
      mode = "777";
    };
  };

  nix = {
    package = pkgs.nixUnstable;

    settings = rec {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;

      trusted-users = [ "@wheel" username ];
      allowed-users = trusted-users;

      # Allow accessing secrets from the sandbox
      extra-sandbox-paths = [
        "/run/agenix"
      ];

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

      # TODO: preferably I would want this in the user environment instead, but agenix doesnt support home-manager
      (pkgs.sm64ex.overrideAttrs (attrs: {
        baseRom = config.age.secrets.sm64.path;

        # Patch i wrote to return to the title screen within the ingame options menu
        patches = attrs.patches or [] ++ [(pkgs.fetchpatch {
          url = "https://sm64pc.info/downloads/patches/leave_game.patch";
          sha256 = "sha256-2b7kLZjKY3BcW+Nj57pN7SMuaiUis7KzPdEU+fQ0Tu8=";
          name = "sm64ex-leave-game.patch";
        })];
      }))
    ];
  };
}
