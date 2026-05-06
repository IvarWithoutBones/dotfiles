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

    links."10-usb-ethernet" = {
      linkConfig = {
        Description = "USB Ethernet adapter";
        Name = "eth-usb0";
        NamePolicy = ""; # Required for our rename to apply
      };

      matchConfig = {
        PermanentMACAddress = "00:e0:4c:36:08:b6";
        Type = "ether";
      };
    };

    networks = {
      "10-usb-dhcpserver" = {
        networkConfig.Description = "Network for devices on USB Ethernet";
        matchConfig.PermanentMACAddress = "00:e0:4c:36:08:b6";
        linkConfig.RequiredForOnline = "no"; # Don't block the boot sequence if not plugged in.

        networkConfig = {
          DNS = "192.168.2.1";
          DHCPServer = true;
        };

        dhcpServerConfig = {
          EmitDNS = false;
          EmitNTP = false;
          EmitSIP = false;
          EmitRouter = false;
        };

        addresses = lib.toList {
          Address = "192.168.7.18/30";
        };

        routes = lib.toList {
          Gateway = "192.168.7.17";
          Metric = 1030; # Make sure this has a lower priority than any other interface.
        };
      };

      "35-wireless" = {
        networkConfig.Description = "Generic wireless interface";
        matchConfig.WLANInterfaceType = "station";
        linkConfig.RequiredForOnline = "routable";

        # Ensure that wireless interfaces have a lower priority than wired interfaces.
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
