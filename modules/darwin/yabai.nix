{ lib
, pkgs
, config
, ...
}:

{
  services.yabai = {
    enable = true;
    package = pkgs.yabai; # Why isnt this the default?
    enableScriptingAddition = true;

    config = {
      layout = "bsp";
      window_shadow = false;
      status_bar = false; # Seems to fix flickering issues

      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
    };

    extraConfig = ''
      yabai -m rule --add app='System Preferences' manage=off
      yabai -m rule --add app='Boot Camp Assistant' manage=off
      yabai -m rule --add app='Widgets Manager' manage=off # From pock
    '';
  };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      # Navigation
      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east

      # Moving windows
      shift + alt - h : yabai -m window --warp west
      shift + alt - j : yabai -m window --warp south
      shift + alt - k : yabai -m window --warp north
      shift + alt - l : yabai -m window --warp east
    '';
  };
}
