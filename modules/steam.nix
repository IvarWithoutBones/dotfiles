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
        er-patcher # Elden Ring enhancement patches
      ];
    };
  };
}
