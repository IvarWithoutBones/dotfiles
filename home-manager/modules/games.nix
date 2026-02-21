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

  # Use IFD to avoid a complicated eval-time secret mechanism. This has the downside of storing the credentials in the Nix store,
  # but since they only allow downloading Factorio that's not really an issue.
  factorio-space-age = pkgs.factorio-space-age.override (
    import (
      pkgs.requireFile {
        name = "factorio-credentials.nix";
        hash = "sha256-zqDqq05QOiShzrnnhtz2dpqzPkSTt7APOSvCTUJC8Co="; # nix hash file --type sha256 --sri ./factorio-credentials.nix
        message = ''
          missing Factorio download credentials. To add these, create a file named "factorio-credentials.nix"
          with the following contents (using the information from https://factorio.com/profile):

          {
            username = "<username>";
            token = "<token>";
          }

          Add it to the Nix store, create a GC root and delete the original:
          nix-store --realize $(nix store add --mode flat ./factorio-credentials.nix) --add-root ./factorio-credentials.nix.gcroot
          rm ./factorio-credentials.nix
        '';
      }
    )
  );
in
{
  home.packages = with pkgs; [
    shipwright
    prismlauncher
    ares
    yafc-ce
    apotris
    factorio-space-age

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
