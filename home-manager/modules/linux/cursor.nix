{
  config,
  lib,
  pkgs,
  ...
}:

# The cursor used in the graphical environment.

{
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    sway.enable = config.wayland.windowManager.sway.enable;
    x11.enable = config.xsession.enable;

    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = lib.mkDefault 20;
  };
}
