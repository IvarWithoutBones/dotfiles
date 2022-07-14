{ config
, lib
, pkgs
, wayland
, ...
}:

let
  dracula-theme = pkgs.lib.importJSON (pkgs.runCommand "yaml-to-json"
    {
      nativeBuildInputs = [ pkgs.yaml2json ]; # We can only import json data
      src = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/dracula/alacritty/05faff15c0158712be87d200081633d9f4850a7d/dracula.yml";
        sha256 = "sha256-NpslJeY3ImllQSbvZXJj7NzjyJbXr8woXlCLaPfOxow=";
        name = "alacritty-dracula-theme.yaml";
      };
    } ''
    yaml2json < $src > $out
  '');
in
{
  home.sessionVariables.TERMINAL = "alacritty";

  programs.alacritty = {
    enable = true;

    settings = {
      inherit (dracula-theme) colors;

      font = {
        normal.family = "FiraCode Nerd Font"; # TODO: inherit this from i3-sway/theme.nix
        size = 10.0;
      } // lib.optionalAttrs wayland {
        # For some reason the font looks a bit smaller on wayland
        size = 13.5;
      };

      key_bindings =
        let
          mod = "Alt";
        in
        [
          {
            mods = mod;
            key = "C";
            action = "Copy";
          }
          {
            mods = mod;
            key = "V";
            action = "Paste";
          }

          {
            mods = "Shift|${mod}";
            key = "K";
            action = "ScrollLineUp";
          }
          {
            mods = "Shift|${mod}";
            key = "J";
            action = "ScrollLineDown";
          }
          {
            mods = "Shift|${mod}";
            key = "U";
            action = "ScrollPageUp";
          }

          {
            mods = mod;
            key = "F";
            mode = "~Search";
            action = "SearchForward";
          }
        ];
    };
  };
}
