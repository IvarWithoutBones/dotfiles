{ lib
, pkgs
, ...
}:

{
  home.sessionVariables.TERMINAL = "alacritty";

  programs.alacritty = {
    enable = true;

    settings = {
      general.import = [
        # The Catppuccin Mocha theme
        (pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/alacritty/f2da554ee63690712274971dd9ce0217895f5ee0/catppuccin-mocha.toml";
          hash = "sha256-nmVaYJUavF0u3P0Qj9rL+pzcI9YQOTGPyTvi+zNVPhg=";
        })
      ];

      font = {
        normal.family = "FiraCode Nerd Font";
        size = lib.mkDefault 10.0;
      };

      keyboard.bindings =
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
        ];
    };
  };
}
