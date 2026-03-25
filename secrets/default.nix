{
  lib,
  system,
  pkgs,
  ivar-dotfiles,
  ...
}:

# Secret management using sops-nix. Used on NixOS, nix-darwin and home-manager.
# To edit a file containing secrets, run `sops edit <path>`.
# To edit the host secrets, run `SOPS_AGE_KEY_FILE=/var/run/secrets.d/age-keys.txt EDITOR=nvim sops edit <path>` as root.
# To add new keys that are allowed to see the secrets, add it to `.sops.yaml` and run `sops updatekeys <path>`.

let
  inherit (ivar-dotfiles.inputs) sops-nix;
  isLinux = lib.elem system lib.systems.doubles.linux; # We cannot use `hostPlatform.isLinux` because imports cannot depend on `config`.
in
{
  imports = [
    (if isLinux then sops-nix.nixosModules.sops else sops-nix.darwinModules.sops)
  ];

  sops = {
    # Should contain the private key that sops will use to encrypt and decrypt secrets. Must be created manually with something like:
    # $ cat /etc/ssh/ssh_host_ed25519_key | ssh-to-age -private-key > /var/lib/sops-nix/key.txt
    # $ chown root:root /var/lib/sops-nix/key.txt
    # $ chmod 600 /var/lib/sops-nix/key.txt
    age.keyFile = "/var/lib/sops-nix/key.txt";
    defaultSopsFile = ./shared.yaml;
  };

  environment.systemPackages = [
    pkgs.sops
    pkgs.age
    pkgs.ssh-to-age
  ];

  # Also register the home-manager module
  home-manager.sharedModules = [
    sops-nix.homeManagerModules.sops
    (
      { config, ... }:
      {
        sops = {
          # Must also be created manually, see above.
          age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
          defaultSopsFile = ./shared.yaml;
        };
      }
    )
  ];
}
