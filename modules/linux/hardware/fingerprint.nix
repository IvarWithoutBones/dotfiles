{ config, lib, ... }:

# Support for fingerprint readers.

{
  services.fprintd.enable = true;

  security.pam.services = {
    # Do not allow initial login with fingerprint, it is not secure enough to unlock gnome-keyring.
    login.fprintAuth = false;
    greetd = lib.mkIf config.services.greetd.enable { fprintAuth = false; };
  };
}
