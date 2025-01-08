{ config
, lib
, ...
}:

# Used in conjunction with `home-manager/modules/linux/keyring.nix`.

{
  services.gnome.gnome-keyring.enable = true;

  # Unlock gnome-keyring when the user logs in to the graphical session.
  security.pam.services.greetd = lib.mkIf config.services.greetd.enable {
    enableGnomeKeyring = true;
  };
}
