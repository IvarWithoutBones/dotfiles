{ pkgs
, wayland
, ...
}:

let
  theme = pkgs.runCommand "alacritty-catpuccin-theme.yml"
    {
      src = pkgs.fetchurl {
        name = "alacritty-catpuccin-theme.yml";
        url = "https://raw.githubusercontent.com/catppuccin/alacritty/c2d27714b43984e47347c6d81216b7670a3fe07f/catppuccin.yml";
        sha256 = "sha256-NFOOBFtLZqoURD4Xv2rtdfG5yvu57MgNddZJX5dZBZU=";
      };
    } ''
    cp $src $out
    # Set the preferred variant of the theme
    substituteInPlace $out --replace "colors: *macchiato" "colors: *mocha"
  '';

  fontSize =
    if wayland then 13.5
    else if pkgs.stdenvNoCC.isDarwin then 15.5
    else 10.0;
in
{
  home.sessionVariables.TERMINAL = "alacritty";

  programs.alacritty = {
    enable = true;

    settings = {
      import = [ theme ];

      font = {
        normal.family = "FiraCode Nerd Font";
        size = fontSize;
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
        ];
    };
  };
}
