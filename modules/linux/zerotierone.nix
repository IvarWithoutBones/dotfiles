{
  ...
}:

{
  services.zerotierone = {
    enable = true;

    joinNetworks = [
      # Personal network
      "fada62b015a4a130"
      # Queens & co
      "8286ac0e47868413"
      # Laptop and phone
      "12ac4a1e719ff42c"
    ];
  };
}
