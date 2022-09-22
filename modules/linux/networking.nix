{ pkgs
, lib
, username
, hostname
, network
, ...
}:

{
  users.users.${username}.extraGroups = [ "networkmanager" ];

  networking = {
    hostName = hostname;
    networkmanager.enable = true;

    interfaces = {
      ${network.interface}.ipv4.addresses = [{
        address = network.address;
        prefixLength = 28;
      }];
    };
  };

  programs.ssh = {
    setXAuthLocation = true;
  };

  services = {
    openssh = {
      enable = true;
      forwardX11 = true;
    };

    zerotierone = {
      enable = true;

      joinNetworks = [
        # Personal network
        "12ac4a1e719ff42c"
        # queens & co
        "8286ac0e47868413"
      ];
    };
  };
}
