{ config
, pkgs
, lib
, ...
}:

let
  yabai = "${pkgs.yabai}/bin/yabai";
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
  navigateWindow = stack: bsp: pkgs.writeShellScript "yabai-navigate" ''
    layout="$(${yabai} -m query --spaces | ${pkgs.jq}/bin/jq -r '.[] | select(."has-focus" == true) | .type')"

    if [[ "$layout" = "stack" ]]; then
      ${yabai} -m window --layer ${stack}
    elif [[ "$layout" = "bsp" ]]; then
      ${yabai} -m window --focus ${bsp}
    fi
  '';
in
{
  # Extended skhd configuration module. TODO: remove this when it gets merged in nix-darwin.
  # https://github.com/LnL7/nix-darwin/pull/525
  imports = [ ./module.nix ];

  services.skhd-custom = {
    enable = true;

    keybindings = {
      "alt - h" = "${yabai} -m window --focus west";
      "alt - j" = navigateWindow "below" "south";
      "alt - k" = navigateWindow "above" "north";
      "alt - l" = "${yabai} -m window --focus east";

      # Change the window layout
      "shift + alt - h" = "${yabai} -m window --warp west";
      "shift + alt - j" = "${yabai} -m window --warp south";
      "shift + alt - k" = "${yabai} -m window --warp north";
      "shift + alt - l" = "${yabai} -m window --warp east";
      "alt - r" = "${yabai} -m space --balance";
      "alt - w" = "${yabai} -m space --layout stack";
      "shift + alt - v" = "${yabai} -m space --layout bsp";

      # Focus a space
      "shift + alt - f" = "${yabai} -m window --toggle native-fullscreen";
      "alt - f" = "${yabai} -m window --toggle zoom-fullscreen";
      "shift + alt - space" = "${yabai} -m window --toggle float";
      "alt - q" = "${yabai} -m window --close";

      # Restart the WM + hotkey daemon
      "shift + alt - r" = "launchctl kickstart -k gui/\${UID}/org.nixos.yabai && launchctl kickstart -k gui/\${UID}/org.nixos.skhd";

      # Application shortcuts
      "alt - return" = "open -n ${pkgs.kitty}/Applications/kitty.app";
      "shift + alt - d" = "open -n ${pkgs.discord}/Applications/Discord.app";
      "ctrl + shift + alt - d" = "killall discord";
      # TODO: switch to purely provided firefox until qtwebengine builds on darwin :/
      "shift + alt - w" = "yabai -m space --focus 2 && open -F /Applications/Firefox.app";

      # Moving focus and windows to different spaces
    } // mkSpaceShortcut "alt" "${yabai} -m space --focus"
    // mkSpaceShortcut "shift + alt" "${yabai} -m window --space";
  };
}
