let
  nixos-pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIq5SRfDXbFH9/fol7s/frJ+uU70Q/9bu0izPLuJ1mps";
  nixos-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILT7/wFdTvzSmdHekW28OAcFT4yVxvmKlAs2VejFjt5l";

  # Used for decrypting on CI
  github-actions = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjjKmSku6t9i2/CtR96u1NIAInRtCq/XnfHROpD+DRE";

  systems = [ nixos-pc nixos-laptop github-actions ];
in {
  "cachix-config.age".publicKeys = systems;
  "sm64.age".publicKeys = systems;
}
