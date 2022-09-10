{ lib
, config
, ...
}:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        # Elden Ring enhancement patches
        (er-patcher.overrideAttrs (attrs: {
          version = "1.04-1+date=2022-06-16";

          # Set this manually for now until the next release is in nixpkgs
          src = fetchFromGitHub rec {
            owner = "gurrgur";
            repo = "er-patcher";
            rev = "fd1a1a4f99fdb9c9ff684ef1591a56da977ecb41";
            sha256 = "1vz1kc4gzq0kipwsh9xkc1cyk26kz018zmanv4bpdg6dw8rsycdn";
          };

          patches = [
            (fetchpatch {
              name = "disable-runeloss.patch";
              url = "https://github.com/gurrgur/er-patcher/pull/41/commits/0f39247ab7bf0da6b77cac34aed6db969076b8d5.patch";
              sha256 = "sha256-HpVA+WRt0Tpg86lAom3Kzcfkf1w9zhGJYTZV5V0mbGc=";
            })
          ];
        }))
      ];
    };
  };
}
