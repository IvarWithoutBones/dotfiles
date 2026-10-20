{ ... }:

# Share notifications, files, clipboard and more between devices.
# Used in conjunction with `home-manager/modules/linux/kde-connect.nix`, this file is needed to open firewall ports.

{
  programs.kdeconnect = {
    enable = true;
    package = null; # Let home-manager pick
  };
}
