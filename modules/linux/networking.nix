{
  lib,
  ...
}:

let
  openPorts = [
    1285 # For streaming audio to other devices using this script: https://gist.github.com/IvarWithoutBones/944af61598a7da0e798a2474bcce1ceb
    34197 # Factorio
  ];
in
{
  networking = {
    useNetworkd = true;
    firewall = {
      allowedTCPPorts = openPorts;
      allowedUDPPorts = openPorts;
    };
  };

  systemd.network = {
    enable = true;
    config.networkConfig.IPv6PrivacyExtensions = "kernel";

    links."10-enusb0" = {
      linkConfig.Description = "USB Ethernet connection";
      matchConfig.PermanentMACAddress = "be:3c:70:91:55:eb";
      linkConfig.Name = "enusb0";
    };

    networks = {
      "35-enusb0-dhcpserver" = {
        networkConfig.Description = "Network for devices on USB Ethernet";
        matchConfig.Name = "enusb0";

        # Don't block the boot sequence if not plugged in.
        linkConfig.RequiredForOnline = "no";
        dhcpServerConfig.DNS = "9.9.9.9";

        networkConfig = {
          DHCPServer = true;
          IPMasquerade = "yes";
          Address = "192.168.7.18/30";
        };

        routes = lib.toList {
          Gateway = "192.168.7.17";
        };
      };

      "35-wireless" = {
        matchConfig.WLANInterfaceType = "station";
        linkConfig.RequiredForOnline = "routable";
        dhcpV4Config.RouteMetric = 1025;
        ipv6AcceptRAConfig.RouteMetric = 1025;

        networkConfig = {
          DHCP = "yes";
          IgnoreCarrierLoss = "3s";
        };
      };
    };
  };

  services.openssh.enable = true;
  programs.mosh.enable = true;
}
