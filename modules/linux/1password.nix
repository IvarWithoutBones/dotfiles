{ config, lib, ... }:

# Sets up the polkit rules for the 1Password password manager's CLI and GUI, needed for keyring/browser integration.
# See `profiles.nix` for the users that the polkit rules are applied to.

{
  programs._1password.enable = true; # CLI

  # Enable the GUI only if a graphical session is enabled (which greetd starts).
  programs._1password-gui.enable = lib.mkDefault (
    config.services.greetd.enable || config.services.xserver.enable
  );
}
