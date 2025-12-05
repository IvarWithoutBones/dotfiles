{ pkgs, config, ... }:

let
  celeste = pkgs.celestegame.override {
    withEverest = true;
    writableDir = "${config.xdg.dataHome}/celeste-nix";
    overrideSrc = pkgs.requireFile {
      name = "celeste-linux.zip";
      sha256 = "11px388n6fkxwxkkh1fdsyfc8pq8fiqg9jgkh37kfvrvyiy7zqj3";
      url = "https://maddymakesgamesinc.itch.io/celeste";
    };
  };
in
{
  home.packages = with pkgs; [
    proton-ge-runner # From my overlay
    prismlauncher
    ares

    celeste
    (loenn.override {
      # Celeste level editor, from my overlay
      withCeleste = true;
      celestegame = celeste;
    })
  ];
}
