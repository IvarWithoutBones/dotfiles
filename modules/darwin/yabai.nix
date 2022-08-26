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
      yabai -m rule --add app='System Information' manage=off
      yabai -m rule --add app='Widgets Manager' manage=off # From pock
    '';
  };

  environment.systemPackages = with pkgs; [
    yabai-zsh-completions
  ];

  services.skhd = {
    enable = true;
    skhdConfig =
      let
        # Number 10 is created manually because of the conflicting hotkey (0) and space number
        spaces = [ 1 2 3 4 5 6 7 8 9 ];

        navigateWindow = stack: bsp: pkgs.writeShellScript "yabai-navigate" ''
          layout="$(yabai -m query --spaces | ${pkgs.jq}/bin/jq -r '.[] | select(."has-focus" == true) | .type')"

          if [[ "$layout" = "stack" ]]; then
            yabai -m window --layer ${stack}
          elif [[ "$layout" = "bsp" ]]; then
            yabai -m window --focus ${bsp}
          fi
        '';
      in
      ''
        # Navigation
        alt - h : yabai -m window --focus west
        alt - j : ${navigateWindow "below" "south"}
        alt - k : ${navigateWindow "above" "north"}
        alt - l : yabai -m window --focus east

        # Change the window layout
        shift + alt - h : yabai -m window --warp west
        shift + alt - j : yabai -m window --warp south
        shift + alt - k : yabai -m window --warp north
        shift + alt - l : yabai -m window --warp east
        alt - r : yabai -m space --balance

        # Layouts
        shift + alt - w : yabai -m space --layout stack
        shift + alt - v : yabai -m space --layout bsp

        # Focus a space
        ${lib.concatStringsSep "\n" (map (num:
        "alt - ${builtins.toString num} : yabai -m space --focus ${builtins.toString num}") spaces)}
        alt - 0 : yabai -m space --focus 10

        # Move windows between spaces
        ${lib.concatStringsSep "\n" (map (num:
        "shift + alt - ${builtins.toString num} : yabai -m window --space ${builtins.toString num}") spaces)}
        shift + alt - 0 : yabai -m window --space 10

        # Window toggles
        shift + alt - f : yabai -m window --toggle native-fullscreen
        alt - f : yabai -m window --toggle zoom-fullscreen
        shift + alt - space : yabai -m window --toggle float
        alt - q : yabai -m window --close

        # Restart the WM + hotkey daemon
        shift + alt - r : launchctl kickstart -k "gui/''${UID}/org.nixos.yabai" && launchctl kickstart -k "gui/''${UID}/org.nixos.skhd"
      '';
  };
}
