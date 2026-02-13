{
  config,
  lib,
  pkgs,
  ...
}:

let
  commonPortals = {
    default = [ "gtk" ];
  }
  // lib.optionalAttrs config.services.gnome-keyring.enable {
    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };
in
{
  xdg = {
    enable = true;
    terminal-exec.enable = true;
    mimeApps.enable = true;

    # Avoid activation failures when the mimeapps file already exists, as some packages will overwrite it:
    # https://github.com/nix-community/home-manager/issues/1213.
    configFile."mimeapps.list".force = true;

    portal = {
      enable = true;
      xdgOpenUsePortal = true;

      config = {
        common = commonPortals;
        sway = lib.optionalAttrs config.wayland.windowManager.sway.enable commonPortals // {
          "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        };
      };

      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ]
      ++ lib.optionalAttrs config.services.gnome-keyring.enable [
        pkgs.gnome-keyring
      ]
      ++ lib.optionals config.wayland.windowManager.sway.enable [
        # Implements various screen sharing APIs for wlroots-based compositors
        pkgs.xdg-desktop-portal-wlr
      ];
    };
  };

  # In order to start applications specified in desktop files the xdg-desktop-portal service
  # needs to be able to find them in its `$PATH`. Because these services aren't defined by
  # Nix we cannot modify the service definition, we instead do so for all user services.
  systemd.user.sessionVariables.PATH = "${config.home.profileDirectory}/bin";
}
