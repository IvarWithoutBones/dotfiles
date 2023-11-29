{ pkgs
, ...
}:

{
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;

    config.common.default = "gtk";
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
