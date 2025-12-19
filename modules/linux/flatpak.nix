{ ... }:

{
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;

    # Don't pick system-wide, allow home-manager to choose in `home-manager/modules/linux/xdg.nix`
    config.common.default = "*";
  };
}
