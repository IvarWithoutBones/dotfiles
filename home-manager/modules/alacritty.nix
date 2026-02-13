{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Set Alacritty as the default terminal emulator
  home.sessionVariables.TERMINAL = "alacritty";

  xdg = lib.mkIf config.xdg.enable {
    terminal-exec.settings = lib.mkIf config.xdg.terminal-exec.enable {
      default = [ "Alacritty.desktop" ];
    };

    mimeApps.defaultApplications = lib.mkIf config.xdg.mimeApps.enable {
      "x-scheme-handler/terminal" = "Alacritty.desktop";
    };
  };

  programs.alacritty = {
    enable = true;

    settings = {
      scrolling.history = 100000;
      font.normal.family = "FiraCode Nerd Font";

      general.import = [
        # The Catppuccin Mocha theme
        (pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/alacritty/f2da554ee63690712274971dd9ce0217895f5ee0/catppuccin-mocha.toml";
          hash = "sha256-nmVaYJUavF0u3P0Qj9rL+pzcI9YQOTGPyTvi+zNVPhg=";
        })
      ];

      keyboard.bindings = [
        # Copy/pasting to the system clipboard
        {
          mods = "alt";
          key = "C";
          action = "Copy";
        }
        {
          mods = "alt";
          key = "V";
          action = "Paste";
        }

        # Scroll one line up/down
        {
          mods = "Shift|Alt";
          key = "K";
          action = "ScrollLineUp";
        }
        {
          mods = "Shift|Alt";
          key = "J";
          action = "ScrollLineDown";
        }

        # Scroll up/down by half a page
        {
          mods = "Shift|Alt";
          key = "U";
          action = "ScrollPageUp";
        }
        {
          mods = "Shift|Alt";
          key = "D";
          action = "ScrollPageDown";
        }
      ]
      ++ lib.optionals (lib.hasAttr "SHELL_PROMPT_MARKER" config.home.sessionVariables) [
        # Jump to previous/next prompt in scrollback. Taken from: https://github.com/alacritty/alacritty/issues/5850#issuecomment-3570435051
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "ToggleViMode";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "ScrollLineUp";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "ScrollLineUp";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "ScrollLineUp";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "SearchBackward";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          chars = config.home.sessionVariables.SHELL_PROMPT_MARKER;
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "SearchConfirm";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "CenterAroundViCursor";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "ToggleViMode";
        }

        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          action = "ScrollLineUp";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          action = "ScrollLineUp";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          action = "ScrollLineUp";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          action = "SearchBackward";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          chars = config.home.sessionVariables.SHELL_PROMPT_MARKER;
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          action = "SearchConfirm";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          action = "CenterAroundViCursor";
        }

        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "ToggleViMode";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "ScrollLineDown";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "ScrollLineDown";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "ScrollLineDown";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "SearchForward";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          chars = config.home.sessionVariables.SHELL_PROMPT_MARKER;
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "SearchConfirm";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "CenterAroundViCursor";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "~Vi|~Search";
          action = "ToggleViMode";
        }

        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          action = "ScrollLineDown";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          action = "ScrollLineDown";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          action = "ScrollLineDown";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          action = "SearchForward";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          chars = config.home.sessionVariables.SHELL_PROMPT_MARKER;
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          action = "SearchConfirm";
        }
        {
          mods = "Alt";
          key = "ArrowUp";
          mode = "Vi";
          action = "CenterAroundViCursor";
        }
      ];
    };
  };
}
