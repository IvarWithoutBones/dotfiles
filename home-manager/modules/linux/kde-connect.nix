{ ... }:

# Share notifications, files, clipboard and more between devices.
# Used in conjunction with `modules/linux/desktop/kde-connect.nix`, which opens firewall ports.

{
  services.kdeconnect = {
    enable = true;
    indicator = false; # Already shown in the bar
  };
}
