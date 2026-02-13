{
  # Supplied by the flake.
  pname,
  version,
  src,
  craneLib,
  # Supplied by nixpkgs.
  lib,
}:

let
  args = {
    inherit pname version src;
    strictDeps = true;

    # Tests are only ran in `passthru.tests.cargo-test` (which overwrites this) to avoid having to re-run them on each output.
    doCheck = false;
  };

  # Build the Cargo dependencies seperately so that the checks don't have to redundantly recompile them.
  argsWithArtifacts = args // {
    cargoArtifacts = craneLib.buildDepsOnly args;
  };
in
craneLib.buildPackage (
  argsWithArtifacts
  // {
    passthru.tests = {
      cargo-test = craneLib.cargoTest (
        argsWithArtifacts
        // {
          doCheck = true;
          cargoTestArgs = "--all-features";
        }
      );

      cargo-clippy = craneLib.cargoClippy (
        argsWithArtifacts
        // {
          cargoClippyExtraArgs = "--all-targets -- --deny warnings";
        }
      );

      cargo-doc = craneLib.cargoDoc (
        argsWithArtifacts
        // {
          RUSTDOCFLAGS = "--deny warnings";
        }
      );

      toml-fmt = craneLib.taploFmt (
        args
        // {
          src = lib.sources.sourceFilesBySuffices src [ ".toml" ];
        }
      );

      cargo-fmt = craneLib.cargoFmt args;
    };
  }
)
