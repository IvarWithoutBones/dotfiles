{ lib
, ...
}:

let
  # Creates keybindings that apply in the vi-insert, vi-command and emacs modes
  mkKeyBindings = bindings: lib.concatMapStringsSep "\n"
    (binding: ''
      $if mode=vi
        set keymap vi-command
        ${binding}
        set keymap vi-insert
        ${binding}
      $else
        ${binding}
      $endif
    '')
    bindings;
in
{
  programs.readline = {
    enable = true;

    variables = {
      colored-stats = true;
      history-size = 10000;
      expand-tilde = true;
      echo-control-characters = false;

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

    extraConfig = mkKeyBindings [
      "Control-l: clear-display"
      # Cycle through completion options
      "TAB: menu-complete"
      "\"\\e[Z\": menu-complete-backward" # Shift-tab
    ];
  };
}
