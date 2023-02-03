{ config
, pkgs
, lib
, ...
}:

let
  yabai = "${pkgs.yabai}/bin/yabai";
  jq = "${pkgs.jq}/bin/jq";
  spaces = [ 1 2 3 4 5 6 7 8 9 10 ];

  # Shorthand to generate shortcut attributes for all spaces
  mkSpaceShortcut = modifier: command: lib.foldl' lib.mergeAttrs { } (map
    (index:
      let
        key = if (index == 10) then 0 else index;
      in
      { "${modifier} - ${toString key}" = "${command} ${toString index}"; })
    spaces);

  # Switch the focus between windows in both stack and bsp modes
  navigateWindow = stack: bsp: pkgs.writeShellScript "yabai-navigate.sh" ''
    layout="$(${yabai} -m query --spaces | ${jq} -r '.[] | select(."has-focus" == true) | .type')"

    if [[ "$layout" = "stack" ]]; then
      ${yabai} -m window --layer ${stack}
    elif [[ "$layout" = "bsp" ]]; then
      ${yabai} -m window --focus ${bsp}
    fi
  '';

  # Move the currently focused space to another display
  moveSpaceBetweenWindows = pkgs.writeShellScript "move-space-between-windows.sh" ''
    currentDisplay="$(${yabai} -m query --spaces | ${jq} -r '.[] | select(."has-focus" == true) | .display')"
    otherDisplay="$(${yabai} -m query --displays \
      | ${jq} -r --argjson space "$currentDisplay" '.[] | select(.index != $space) | .index')"

    ${yabai} -m space --create # Ensure there is at least one available space
    ${yabai} -m space --display "$otherDisplay"
    ${yabai} -m display --focus "$otherDisplay"
  '';
in
{
  # Extended skhd configuration module. TODO: remove this when it gets merged in nix-darwin.
  # https://github.com/LnL7/nix-darwin/pull/525
  imports = [ ./module.nix ];

  services.skhd-custom = {
    enable = true;

    keybindings = {
      "shift + alt - h" = "${yabai} -m window --focus west";
      "shift + alt - j" = navigateWindow "below" "south";
      "shift + alt - k" = navigateWindow "above" "north";
      "shift + alt - l" = "${yabai} -m window --focus east";

      # Focus a different monitor
      "alt - n" = "${yabai} -m display --focus recent";
      "alt + shift - n" = moveSpaceBetweenWindows;

      # Change the window layout
      "ctrl + shift + alt - h" = "${yabai} -m window --warp west";
      "ctrl + shift + alt - j" = "${yabai} -m window --warp south";
      "ctrl + shift + alt - k" = "${yabai} -m window --warp north";
      "ctrl + shift + alt - l" = "${yabai} -m window --warp east";
      "alt - r" = "${yabai} -m space --balance";
      "alt - w" = "${yabai} -m space --layout stack";
      "shift + alt - v" = "${yabai} -m space --layout bsp";

      # Focus a space
      "shift + alt - f" = "${yabai} -m window --toggle native-fullscreen";
      "alt - f" = "${yabai} -m window --toggle zoom-fullscreen";
      "shift + alt - space" = "${yabai} -m window --toggle float";
      "shift + alt - q" = "${yabai} -m window --close";

      # Restart the WM + hotkey daemon
      "shift + alt - r" = "launchctl kickstart -k gui/\${UID}/org.nixos.yabai && launchctl kickstart -k gui/\${UID}/org.nixos.skhd";

      # Application shortcuts
      "alt - return" = "open -n ${pkgs.iterm2}/Applications/iTerm2.app";
      "shift + alt - d" = "open -n ${pkgs.discord}/Applications/Discord.app";
      "ctrl + shift + alt - d" = "killall discord";
      "shift + alt - w" = "yabai -m space --focus 2 && open -n ${pkgs.qutebrowser}/Applications/qutebrowser.app";

      # Moving focus and windows to different spaces
    } // mkSpaceShortcut "alt" "${yabai} -m space --focus"
    // mkSpaceShortcut "shift + alt" "${yabai} -m window --space";
  };
}
