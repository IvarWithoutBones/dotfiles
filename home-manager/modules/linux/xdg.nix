{ config, lib, pkgs, ... }:

let
  commonPortals = {
    default = [ "gtk" ];
  } // lib.optionalAttrs config.services.gnome-keyring.enable {
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
      ] ++ lib.optionals config.wayland.windowManager.sway.enable [
        # Implements various screen sharing APIs for wlroots-based compositors
        pkgs.xdg-desktop-portal-wlr
      ];
    };
  };
}
