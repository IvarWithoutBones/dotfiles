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
        (er-patcher.overrideAttrs (attrs: rec {
          version = "1.06-3";

          src = fetchFromGitHub {
            owner = "gurrgur";
            repo = "er-patcher";
            rev = "v${version}";
            sha256 = "sha256-w/5cXxY4ua5Xo1BSz3MYRV+SdvVGFAx53KMIORS1uWE=";
          };
        }))
      ];
    };
  };
}
