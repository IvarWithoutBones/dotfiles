{ pkgs
, lib
, ...
}:

# Configuration for a NixOS virtual machine on which Nix can perform builds if linux-only packages are needed.
# TODO: Use the `nixos-builder` nix-darwin module.

let
  builderScript = pkgs.writeShellScriptBin "nixos-builder" ''
    set -xeuo pipefail

    NIXOS_BUILDER_DIRECTORY="''${NIXOS_BUILDER_DIR:-$HOME/nix/nixos-builder}"
    mkdir -p "$NIXOS_BUILDER_DIRECTORY"
    cd "$NIXOS_BUILDER_DIRECTORY"
    ${pkgs.darwin.linux-builder}/bin/create-builder "''$*"
  '';
in
{
  nix = {
    distributedBuilds = true;

    buildMachines = [{
      hostName = "localhost";
      sshUser = "builder";
      system = "x86_64-linux";
      maxJobs = 10;
      # The script from `pkgs.darwin.builder` will create a matching keypair.
      sshKey = "/etc/nix/builder_ed25519";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=";
    }];
  };

  environment.systemPackages = lib.toList builderScript;
}
