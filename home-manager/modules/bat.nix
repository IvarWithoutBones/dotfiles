{ config
, pkgs
, lib
, ...
}:

let
  # Needed for mouse/gesture scrolling support on MacOS
  pager = "${pkgs.less}/bin/less --mouse --raw-control-chars --wheel-lines=1 --quit-if-one-screen";
in
{
  programs.bat = {
    enable = true;
    config = {
      theme = "catpuccin";
    } // lib.optionalAttrs pkgs.stdenv.isDarwin { inherit pager; };
  };

  # The themes option from the module needs builtins.readFile :/
  xdg.configFile."bat/themes/catpuccin.tmTheme".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/sublime-text/3d8625d937d89869476e94bc100192aa220ce44a/Mocha.tmTheme";
    sha256 = "sha256-D2qufwRF72MvESoYsvOlniBr2zir1y2unPBQ+7Q+AT4=";
  };

  # Cache needs to be rebuild for the themes to show up
  home.activation.bat = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.bat}/bin/bat cache --build 1>/dev/null
  '';

  # Export this so that programs such as delta can use it
  programs.zsh.initExtra = lib.optionalString (pkgs.stdenv.isDarwin && config.programs.zsh.enable) ''
    export BAT_PAGER='${pager}'
  '';
}
