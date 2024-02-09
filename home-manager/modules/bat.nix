{ pkgs, ... }:

{
  programs.bat = {
    enable = true;

    config.theme = "catppuccin";
    themes.catppuccin.src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/catppuccin/sublime-text/3d8625d937d89869476e94bc100192aa220ce44a/Mocha.tmTheme";
      sha256 = "sha256-D2qufwRF72MvESoYsvOlniBr2zir1y2unPBQ+7Q+AT4=";
    };
  };
}
