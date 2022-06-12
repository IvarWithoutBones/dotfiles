{ pkgs
, username
, ...
}:

{
  networking.networkmanager.enable = true;
  users.users.${username}.extraGroups = [ "networkmanager" ];

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
