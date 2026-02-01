{ config, ... }:

{
  programs.less = {
    enable = true;

    options = {
      # Ensures mouse wheel scrolling works properly
      RAW-CONTROL-CHARS = true;

      # Makes searches case-insensitive when the pattern is all lowercase
      ignore-case = true;

      # Automatically exit less if the content fits on one screen
      quit-if-one-screen = true;
    };
  };

  home.sessionVariables = {
    LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
  };
}
