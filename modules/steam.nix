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
          name = "er-patcher-1.06-1+date=2022-08-04";

          # TODO: reomve when https://github.com/gurrgur/er-patcher/pull/41 is merged
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
