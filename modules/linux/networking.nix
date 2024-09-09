{ lib
, username
, hostname
, network
, ...
}:

let
  ethernetDevices = [ "enp0s20f0u4" "enp0s20f0u6" ];
in
{
  users.users.${username}.extraGroups = [ "networkmanager" ];

  networking = {
    hostName = hostname;
    enableIPv6 = false;

    networkmanager = {
      enable = true;
      unmanaged = ethernetDevices;
    };

    interfaces = {
      ${network.interface}.ipv4.addresses = [{
        address = network.address;
        prefixLength = 28;
      }];
    } // lib.genAttrs ethernetDevices (_: {
      ipv4.addresses = [{
        address = "192.168.7.1";
        prefixLength = 24;
      }];
    });
  };

  # Assign an IP address when the device is plugged in rather than on startup. Needed to prevent
  # blocking the boot sequence when the device is unavailable, as it is hotpluggable.
  systemd.services = lib.concatMapAttrs (_: v: v) (lib.genAttrs ethernetDevices (device: {
    "network-addresses-${device}".wantedBy = lib.mkForce [ "sys-subsystem-net-devices-${device}.device" ];
  }));

  services.openssh.enable = true;
  programs.mosh.enable = true;
}
