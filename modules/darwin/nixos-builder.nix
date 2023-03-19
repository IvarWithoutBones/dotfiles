{ pkgs
, lib
, ...
}:

# Configuration for a NixOS virtual machine on which Nix can perform builds if linux-only packages are needed.

let
  builderScript = pkgs.writeShellScriptBin "nixos-builder" ''
    set -xeuo pipefail

    mkdir -p "$HOME/nix/nixos-builder"
    cd "$HOME/nix/nixos-builder"
    ${pkgs.darwin.builder}/bin/create-builder "''$*"
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
