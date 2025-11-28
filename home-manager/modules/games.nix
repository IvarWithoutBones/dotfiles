{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    proton-ge-runner # From my overlay
    prismlauncher
    ares

    loenn # Celeste level editor, from my overlay
    (celestegame.override {
      withEverest = true;
      writableDir = "${config.xdg.dataHome}/celeste-nix";
      overrideSrc = requireFile {
        name = "celeste-linux.zip";
        sha256 = "11px388n6fkxwxkkh1fdsyfc8pq8fiqg9jgkh37kfvrvyiy7zqj3";
        url = "https://maddymakesgamesinc.itch.io/celeste";
      };
    })
  ];
}
