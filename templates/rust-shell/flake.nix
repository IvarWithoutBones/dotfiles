{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
    }:
    let
      inherit (nixpkgs) lib;
      forEachSystem = f: lib.genAttrs lib.systems.flakeExposed (system: f system (mkPkgs system));
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };

      mkDevShell =
        {
          stdenv,
          mkShell,
          buildPackages,
          useNightly ? false,
        }:
        let
          toolchainOverrides = {
            extensions = [
              "rust-src"
              "rustfmt"
              "rust-analyzer"
              "clippy"
            ];
          };

          rustToolchain =
            if useNightly then
              buildPackages.rust-bin.selectLatestNightlyWith (tc: tc.default.override toolchainOverrides)
            else
              buildPackages.rust-bin.stable.latest.default.override toolchainOverrides;
        in
        mkShell {
          name = "rust-${if useNightly then "nightly" else "stable"}";
          strictDeps = true;

          nativeBuildInputs = [
            rustToolchain
          ];

          env = {
            # Set the default target and linker for Cargo in case we're cross-compiling.
            CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTarget;
            "CARGO_TARGET_${stdenv.hostPlatform.rust.cargoEnvVarTarget}_LINKER" = lib.getExe stdenv.cc;
          };
        };
    in
    {
      devShells = forEachSystem (
        system: pkgs: {
          default = self.devShells.${system}.stable;

          stable = pkgs.callPackage mkDevShell { useNightly = false; };
          stable-aarch64 = pkgs.pkgsCross.aarch64-multiplatform.callPackage mkDevShell {
            useNightly = false;
          };

          nightly = pkgs.callPackage mkDevShell { useNightly = true; };
          nightly-aarch64 = pkgs.pkgsCross.aarch64-multiplatform.callPackage mkDevShell {
            useNightly = true;
          };
        }
      );
    };
}
