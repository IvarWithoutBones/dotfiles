{ config
, pkgs
, lib
, ...
}:

{
  programs.bat = {
    enable = true;

    themes = {
      catpuccin = builtins.readFile (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/sublime-text/3d8625d937d89869476e94bc100192aa220ce44a/Mocha.tmTheme";
        sha256 = "sha256-D2qufwRF72MvESoYsvOlniBr2zir1y2unPBQ+7Q+AT4=";
      });
    };

    config.theme = "catpuccin";
  };

  # A cache needs to be rebuild for the themes to show up
  home.activation.bat = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.bat}/bin/bat cache --build 1>/dev/null
  '';
}

