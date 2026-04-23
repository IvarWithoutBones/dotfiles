{ ... }:

# System configuration for Wireshark, a network protocol analyzer.
# Used in conjunction with `home-manager/modules/linux/wireshark.nix`.

{
  programs.wireshark = {
    enable = true;
    dumpcap.enable = true;
    usbmon.enable = true;
  };
}
