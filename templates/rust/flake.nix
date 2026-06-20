{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      crane,
      rust-overlay,
      git-hooks,
      ... # flake-compat
    }:
    let
      forEachSystem = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (sys: f sys (mkPkgs sys));
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            rust-overlay.overlays.default
            self.overlays.default
          ];
        };

      crossArchs = pkgs: [
        pkgs.pkgsCross.gnu64 # x86_64-unknown-linux-gnu
        pkgs.pkgsCross.musl64 # x86_64-unknown-linux-musl
        pkgs.pkgsCross.aarch64-multiplatform # aarch64-unknown-linux-gnu
        pkgs.pkgsCross.aarch64-multiplatform-musl # aarch64-unknown-linux-musl
        pkgs.pkgsCross.mingw-msvcrt-x86_64 # x86_64-w64-mingw32
      ];

      # Note that the `rust-bin` package comes from the `rust-overlay` input.
      mkRustToolchain =
        pkgs:
        (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml).override {
          targets = map (arch: arch.stdenv.hostPlatform.rust.rustcTarget) (crossArchs pkgs);
        };
    in
    {
      formatter = forEachSystem (system: pkgs: pkgs.treefmt);

      overlays.default = final: prev: {
        change-me-project-name = final.callPackage ./crates/change-me-project-name {
          craneLib = (crane.mkLib final).overrideToolchain mkRustToolchain;
          version =
            let
              year = nixpkgs.lib.substring 0 4 self.lastModifiedDate;
              month = nixpkgs.lib.substring 4 2 self.lastModifiedDate;
              day = nixpkgs.lib.substring 6 2 self.lastModifiedDate;
            in
            "${year}-${month}-${day}${if self ? shortRev then "-${self.shortRev}" else ""}";
        };
      };

      packages = forEachSystem (
        system: pkgs: {
          default = self.packages.${system}.change-me-project-name;

          change-me-project-name = pkgs.change-me-project-name.overrideAttrs (oldAttrs: {
            # Add the cross-compilation targets as passthru attributes so that they can be easily accessed from the command line.
            # For example, `nix build .#change-me-project-name.cross.aarch64-unknown-linux-musl` to build for aarch64-unknown-linux-musl.
            passthru = oldAttrs.passthru or { } // {
              cross = nixpkgs.lib.listToAttrs (
                map (arch: {
                  name = arch.stdenv.hostPlatform.config;
                  value = arch.change-me-project-name;
                }) (crossArchs pkgs)
              );
            };
          });
        }
      );

      apps = forEachSystem (
        system: pkgs: {
          default = self.apps.${system}.change-me-project-name;

          change-me-project-name = {
            type = "app";
            program = nixpkgs.lib.getExe self.packages.${system}.change-me-project-name;
            inherit (self.packages.${system}.change-me-project-name) meta;
          };
        }
      );

      checks = forEachSystem (
        system: pkgs:
        let
          rustToolchain = mkRustToolchain pkgs;
        in
        {
          pre-commit = git-hooks.lib.${system}.run {
            package = pkgs.prek;
            src = nixpkgs.lib.sources.sourceFilesBySuffices ./. [
              "rs"
              "Cargo.lock"
              "nix"
              "yml"
              "yaml"
              "md"
              "toml"
              ".editorconfig"
            ];

            settings.rust.check.cargoDeps = pkgs.rustPlatform.importCargoLock {
              lockFile = ./Cargo.lock;
            };

            hooks = {
              editorconfig-checker.enable = true;

              treefmt = {
                enable = true;
                settings.formatters = [
                  rustToolchain.availableComponents.rustfmt
                  pkgs.mdformat
                  pkgs.nixfmt
                  pkgs.yamlfmt
                  pkgs.taplo
                ];
              };

              clippy = {
                enable = true;
                settings.denyWarnings = true;
                packageOverrides = {
                  cargo = rustToolchain;
                  clippy = rustToolchain;
                };
              };
            };
          };
        }
      );

      devShells = forEachSystem (
        system: pkgs:
        let
          mkShell =
            arch: args:
            arch.callPackage ./nix/devshell.nix {
              flake-check-pre-commit = self.checks.${system}.pre-commit;
            }
            // args;

          # Add the cross-compilation targets as passthru attributes so that they can be easily accessed from the command line.
          # For example, `nix develop .#full.cross.aarch64-unknown-linux-musl` to build for aarch64-unknown-linux-musl.
          mkTopLevelShell =
            args:
            (mkShell pkgs args).overrideAttrs (oldAttrs: {
              passthru = oldAttrs.passthru or { } // {
                cross = nixpkgs.lib.listToAttrs (
                  map (arch: {
                    name = arch.stdenv.hostPlatform.config;
                    value = mkShell arch args;
                  }) (crossArchs pkgs)
                );
              };
            });
        in
        {
          default = self.devShells.${system}.full;

          base = mkTopLevelShell {
            withPreCommit = false;
          };

          full = mkTopLevelShell {
            withPreCommit = true;
          };
        }
      );
    };
}
