{ config, pkgs, ... }:

# Configuration for Transmission, a BitTorrent client.

let
  # Allow read/write access to each member in the group, but none for others
  permissions = 770;
  umask = "007";
in
{
  sops.secrets.transmission-rpc-credentials = {
    owner = config.services.transmission.user;
    group = config.services.transmission.group;
  };

  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;

    credentialsFile = config.sops.secrets.transmission-rpc-credentials.path;
    downloadDirPermissions = toString permissions;
    openPeerPorts = true;

    settings = {
      inherit umask;

      # Paths
      incomplete-dir-enabled = false;
      trash-can-enabled = false;

      # RPC
      rpc-enabled = true;
      anti-brute-force-enabled = true;
      rpc-authentication-required = true;
      rpc-username = "transmission-${config.networking.hostName}";

      # Local Peer Discovery
      lpd-enabled = true;

      # Block known bad peers
      blocklist-enabled = true;
      blocklist-url = "https://github.com/Naunter/BT_BlockLists/raw/refs/heads/master/bt_blocklists.gz";
    };
  };

  # Ensure the state directory (in which the download directory is lives) has the appropriate permissions as well,
  # otherwise its subdirectories will inherit the wrong permissions.
  systemd.services.transmission.serviceConfig.StateDirectoryMode = permissions;
}
