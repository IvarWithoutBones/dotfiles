# This file makes it possible to use the development environment from `flake.nix`,
# without requiring flakes to be enabled in the Nix installation. For details, see:
# https://github.com/NixOS/flake-compat/tree/ff81ac966bb2cae68946d5ed5fc4994f96d0ffec
#
# To use it, run `nix-shell` in the same directory as this file.

(import (
  let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    nodeName = lock.nodes.root.inputs.flake-compat;
  in
  fetchTarball {
    url =
      lock.nodes.${nodeName}.locked.url
        or "https://github.com/nixos/flake-compat/archive/${lock.nodes.${nodeName}.locked.rev}.tar.gz";
    sha256 = lock.nodes.${nodeName}.locked.narHash;
  }
) { src = ./.; }).shellNix
