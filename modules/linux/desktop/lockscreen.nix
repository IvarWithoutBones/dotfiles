{
  config,
  ...
}:

# Allow swaylock/i3lock to authenticate the user. They are configured using home-manager.
# Used in conjunction with `home-manager/modules/linux/i3-sway/config/lockscreen.nix`.

{
  security.pam.services = {
    swaylock.enable = true;
    i3lock.enable = config.services.xserver.enable;
  };
}
