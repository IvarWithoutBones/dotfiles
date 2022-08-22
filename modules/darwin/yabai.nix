{ lib
, pkgs
, config
, ...
}:

{
  services.yabai = {
    enable = true;
    package = pkgs.yabai; # TODO: make this the default

    config = {
      layout = "bsp";

      focus_follows_mouse = "autofocus";
      auto_balance = "on";

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
      yabai -m rule --add app='System Information' manage=off
    '';
  };

  environment.systemPackages = with pkgs; [
    yabai-zsh-completions
  ];

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

      # Window toggles
      shift + alt - space : yabai -m window --toggle float
      shift + alt - f : yabai -m window --toggle native-fullscreen
      alt - f : yabai -m window --toggle zoom-fullscreen
      alt - q : yabai -m window --close

      # Restart
      shift + alt - r : launchctl kickstart -k "gui/''${UID}/org.nixos.yabai"
    '';
  };
}
