{
  ivar-dotfiles,
  ...
}:

{
  programs.readline = {
    enable = true;

    variables = {
      colored-stats = true;
      history-size = 10000;
      expand-tilde = true;
      echo-control-characters = false;
      convert-meta = true;

      # VI mode
      editing-mode = "vi";
      show-mode-in-prompt = true;
      vi-cmd-mode-string = ''"\1\e[2 q\2"''; # Block
      vi-ins-mode-string = ''"\1\e[6 q\2"''; # Line
      keyseq-timeout = 150; # Refresh interval for the mode indicator, in milliseconds

      # Completion
      completion-ignore-case = true;
      completion-map-case = true; # Treat '-' and '_' the same
      completion-query-items = -1; # Never ask to list completions
      show-all-if-ambiguous = true;
      show-all-if-unmodified = true;
      page-completions = false;
      menu-complete-display-prefix = true;
    };

    extraConfig = ivar-dotfiles.flake.lib.readlineBindingsAllModes ''
      Control-l: clear-display
      # Cycle through completion options
      TAB: menu-complete
      "\e[Z": menu-complete-backward # Shift-tab
    '';
  };
}
