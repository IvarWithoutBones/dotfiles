{ ...
}:

{
  services.zerotierone = {
    # Disabled until https://github.com/zerotier/ZeroTierOne/issues/2345 is fixed
    enable = true;

    joinNetworks = [
      # Personal network
      "12ac4a1e719ff42c"
      # queens & co
      "8286ac0e47868413"
    ];
  };
}
