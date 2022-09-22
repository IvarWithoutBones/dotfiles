{ config
, lib
, pkgs
, wayland
, ...
}:

let
  # Doing this with IFD is slow, but alacritty doesnt have an `extraConfig` option. :/
  theme = lib.importJSON (pkgs.runCommand "yaml-to-json" {
    nativeBuildInputs = [ pkgs.yaml2json ]; # We can only import json data
    src = pkgs.fetchurl {
      name = "alacritty-catpuccin-theme.yaml";
      url = "https://raw.githubusercontent.com/catppuccin/alacritty/c2d27714b43984e47347c6d81216b7670a3fe07f/catppuccin.yml";
      sha256 = "sha256-NFOOBFtLZqoURD4Xv2rtdfG5yvu57MgNddZJX5dZBZU=";
    };
  } ''
    cp $src ./theme.yml
    substituteInPlace ./theme.yml \
      --replace "colors: *macchiato" "colors: *mocha"

    yaml2json < ./theme.yml > $out
  '');
in
{
  home.sessionVariables.TERMINAL = "alacritty";

  programs.alacritty = {
    enable = true;

    settings = {
      inherit (theme) color_schemes colors;

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
