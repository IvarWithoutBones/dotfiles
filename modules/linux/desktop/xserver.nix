{ ... }:

{
  # Required for some GTK programs.
  programs.dconf.enable = true;

  services.xserver = {
    enable = true;
    enableTearFree = true; # Reduce screen tearing.

    # See `home-manager/modules/linux/i3-sway/input.nix` for Wayland input configuration.
    inputClassSections = [
      # Swap capslock <-> escape on all keyboards.
      ''
        Identifier "keyboard-swap-capslock-escape"
        MatchIsKeyboard "on"
        Option "XkbOptions" "caps:swapescape"
      ''

      # Don't swap capslock <-> escape on keyboards which have their layout configured differently.
      ''
        Identifier "keyboard-dont-swap-capslock-escape-halcyon-elora"
        MatchUSBID "8d1d:a392"
        MatchIsKeyboard "on"
        Option "XkbOptions" "caps:capslock"
      ''
      ''
        Identifier "keyboard-dont-swap-capslock-escape-keychron-q2"
        MatchUSBID "3434:0111"
        MatchIsKeyboard "on"
        Option "XkbOptions" "caps:capslock"
      ''

      # Internal keyboard on Apple laptops.
      ''
        Identifier "keyboard-apple-internal"
        MatchUSBID "05ac:027c"
        MatchIsKeyboard "on"
        Option "XkbOptions" "caps:swapescape,altwin:swap_lalt_lwin"
      ''

      # Halycon Elora trackpad module.
      ''
        Identifier "trackpad-halcyon-elora"
        MatchUSBID "8d1d:a392"
        MatchIsPointer "on"
        Option "AccelProfile" "flat"
        Option "PointerAccel" "0.7"
        Option "ScrollFactor" "2.0"
      ''
    ];
  };

  console.useXkbConfig = true;
}
