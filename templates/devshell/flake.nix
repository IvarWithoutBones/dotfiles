# This file contains a reproducible development environment for MacOS and Linux
# with the dependencies needed for this project, managed by the Nix package manager.
#
# To use it, run `nix develop` in the same directory as this file.

{
  description = "A reproducible development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-compat.url = "github:nixos/flake-compat";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      forEachSystem = f: lib.genAttrs lib.systems.flakeExposed (system: f (mkPkgs system) system);
      mkPkgs = system: import nixpkgs { inherit system; };
    in
    {
      formatter = forEachSystem (pkgs: _system: pkgs.nixfmt-tree);

      devShells = forEachSystem (
        pkgs: system: {
          default = pkgs.mkShell {
            packages = [
              self.formatter.${system}
            ];
          };
        }
      );
    };
}
