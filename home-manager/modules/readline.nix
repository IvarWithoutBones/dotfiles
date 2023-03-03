{ config
, pkgs
, ...
}:

{
  programs.readline = {
    enable = true;

    variables = {
      # VI mode
      editing-mode = "vi";
      show-mode-in-prompt = true;
      vi-cmd-mode-string = ''"\1\e[2 q\2"''; # Block
      vi-ins-mode-string = ''"\1\e[6 q\2"''; # Line
      keyseq-timeout = 150; # Refresh interval for the mode indicator, in milliseconds

      # Completion
      completion-ignore-case = true;
      completion-map-case = true; # Treat '-' and '_' the same
      show-all-if-ambiguous = true;

      history-size = 10000;
      colored-stats = true;
    };
  };
}
