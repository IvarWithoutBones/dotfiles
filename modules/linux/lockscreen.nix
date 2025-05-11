{ wayland
, ...
}:

# Used in conjunction with `home-manager/modules/linux/i3-sway/lockscreen.nix`.

{
  security.pam.services = {
    swaylock.enable = wayland; # Allow swaylock to authenticate the user.
    i3lock.enable = !wayland; # Allow i3lock to authenticate the user.
  };
}
