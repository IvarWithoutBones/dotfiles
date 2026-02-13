{ ... }:

# Used in conjunction with `modules/linux/keyring.nix`.

{
  services.gnome-keyring = {
    enable = true;
    components = [
      "pkcs11"
      "secrets"
      "ssh"
    ];
  };
}
