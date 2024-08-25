{ lib
, wayland
, ...
}:

{
  # Required for some GTK programs
  programs.dconf.enable = true;

  # Without this swaylock cannot authenticate the user
  security.pam.services.swaylock = lib.mkIf wayland { };

  services.gnome.gnome-keyring.enable = true;
}
