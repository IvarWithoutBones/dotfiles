{ config, lib, ... }:

# Application launcher for Wayland

{
  programs.tofi = {
    enable = true;
    settings = {
      # Launch TUI applications in the terminal selected by xdg-terminal-exec.
      terminal = lib.getExe config.xdg.terminal-exec.package;

      # Catppuccin Mocha theme
      text-color = "#cdd6f4";
      background-color = "#12121c";
      selection-color = "#12121c";
      selection-background = "#cba6f7";
      selection-background-padding = "-1,15"; # Fill from bottom to top, with horizontal padding
      prompt-color = "#f38ba8";
      prompt-padding = 15;

      # Make the window look like dmenu's: https://github.com/philj56/tofi/blob/v0.9.1/themes/dmenu
      anchor = "top";
      width = "100%";
      height = 28;
      horizontal = true;
      font-size = 14;
      prompt-text = "\"\""; # No prompt
      font = "monospace";
      clip-to-padding = false;
      outline-width = 0;
      border-width = 0;
      min-input-width = 120;
      result-spacing = 30;
      padding-top = 3; # Centers the text
      padding-bottom = 0;
      padding-left = 0;
      padding-right = 0;
    };
  };
}
