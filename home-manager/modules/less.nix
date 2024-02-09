{ ... }:

{
  programs.less = {
    enable = true;

    # `--RAW-CONTROL-CHARS` is needed for scrolling using the mouse wheel (ironically `--mouse` breaks it)
    # `--IGNORE-CASE` makes searches case-insensitive when the pattern is all lowercase
    keys = ''
      #env
      LESS=--RAW-CONTROL-CHARS --IGNORE-CASE --quit-if-one-screen
    '';
  };
}
