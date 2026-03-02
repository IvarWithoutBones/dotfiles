{
  lib,
  pkgs,
  config,
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
      "10-enusb0-dhcpserver" = {
        networkConfig.Description = "Network for devices on USB Ethernet";
        matchConfig.Name = "enusb0";
        linkConfig.RequiredForOnline = "no"; # Don't block the boot sequence if not plugged in.
        dhcpServerConfig.DNS = "9.9.9.9";

        networkConfig = {
          Address = "192.168.7.18/30";
          DHCPServer = true;
          IPv4Forwarding = true;
          IPv6Forwarding = true;
        };

        routes = lib.toList {
          Gateway = "192.168.7.17";
        };
      };

      "35-wireless" = {
        networkConfig.Description = "Generic wireless interface";
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

    # Wireguard
    netdevs."50-wg-dco" = {
      netdevConfig = {
        Description = "WireGuard interface for DCO";
        Name = "wg-dco";
        Kind = "wireguard";
      };

      wireguardConfig = {
        ListenPort = 51820;
        PrivateKeyFile = config.sops.secrets."wireguard/dco/machines/${config.networking.hostName}".path;
        RouteTable = "main"; # Automatically add routes for peer IPs.
      };

      wireguardPeers = [
        {
          PublicKeyFile = config.sops.secrets."wireguard/dco/public-key".path;
          Endpoint = "@network.wireguard.dco.endpoint";
          AllowedIPs = [ "10.10.10.0/24" ];
          PersistentKeepalive = 25;
        }
      ];
    };
  };

  sops.secrets."wireguard/dco/machines/${config.networking.hostName}" = {
    sopsFile = ../../secrets/${config.networking.hostName}/host.yaml;
    reloadUnits = [ "systemd-networkd.service" ];
    owner = "systemd-network";
  };

  sops.secrets."wireguard/dco/public-key" = {
    reloadUnits = [ "systemd-networkd.service" ];
    owner = "systemd-network";
  };

  sops.secrets."wireguard/dco/endpoint" = {
    reloadUnits = [ "systemd-networkd.service" ];
    path = "/etc/credstore/network.wireguard.dco.endpoint";
    owner = "systemd-network";
  };

  environment.systemPackages = [
    pkgs.wireguard-tools
  ];
}
