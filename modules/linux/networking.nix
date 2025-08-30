{ config
, lib
, ...
}:

let
  ethernetDevices = [ "enp0s20f0u4" "enp0s20f0u6" ];

  openPorts = [
    1285 # For streaming audio to other devices using this script: https://gist.github.com/IvarWithoutBones/944af61598a7da0e798a2474bcce1ceb
    34197 # Factorio
  ];
in
{
  # Add the "networkmanager" group to every normal (i.e. interactive) user so they can change the network settings.
  users.extraGroups."networkmanager".members = lib.attrNames
    (lib.filterAttrs (_username: config: config.isNormalUser) config.users.extraUsers);

  networking = {
    enableIPv6 = true;

    firewall = {
      allowedTCPPorts = openPorts;
      allowedUDPPorts = openPorts;
    };

    networkmanager = {
      enable = true;
      unmanaged = ethernetDevices;
    };

    interfaces = lib.genAttrs ethernetDevices (_: {
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
