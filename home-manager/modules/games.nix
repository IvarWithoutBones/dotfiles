{ config, pkgs, ... }:

let
  celeste = pkgs.celestegame.override {
    writableDir = "${config.xdg.dataHome}/celeste-nix/writable";
    withEverest = true;

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
    yafc-ce

    celeste

    # Celeste level editor, from my overlay
    (loenn.override {
      withCeleste = true;
      celestegame = celeste;
    })

    # Celeste mod manager
    (olympus.override {
      # This adds a stable path (symlinked below) to the Celeste installation directory,
      # without it we'd have to re-select it every time the store path changes.
      finderHints = [ "${config.xdg.dataHome}/celeste-nix/home" ];
    })
  ];

  xdg.dataFile."celeste-nix/home".source = "${celeste.passthru.celeste-unwrapped}/lib/Celeste";
}
