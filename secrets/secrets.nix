let
  nixos-pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIq5SRfDXbFH9/fol7s/frJ+uU70Q/9bu0izPLuJ1mps";
  nixos-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILT7/wFdTvzSmdHekW28OAcFT4yVxvmKlAs2VejFjt5l";

  systems = [ nixos-pc nixos-laptop ];
in {
  "cachix-config.age".publicKeys = systems;
}
