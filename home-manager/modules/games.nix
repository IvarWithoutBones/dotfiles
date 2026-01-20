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
    prismlauncher
    ares
    yafc-ce
    apotris

    celeste
    (loenn.override {
      # Celeste level editor, from my overlay
      withCeleste = true;
      celestegame = celeste;
    })
    (olympus.override {
      # Celeste mod manager
      finderHints = [
        # This adds a stable path (symlinked below) to the Celeste installation directory,
        # without it we'd have to re-select it every time the store path changes.
        "${config.xdg.dataHome}/celeste-nix/home"
      ];
    })

    # From my overlay
    proton-ge-runner
    livesplit-one
  ];

  xdg.dataFile."celeste-nix/home".source = "${celeste.passthru.celeste-unwrapped}/lib/Celeste";
}
