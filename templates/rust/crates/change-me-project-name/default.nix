{
  # From the flake
  version,
  craneLib,
  # From nixpkgs
  lib,
}:

let
  unfilteredSrc = ../..;
  args = {
    pname = "change-me-project-name";
    inherit version;

    src = lib.fileset.toSource {
      root = unfilteredSrc;
      fileset = lib.fileset.unions [
        (craneLib.fileset.commonCargoSources unfilteredSrc)
        (lib.fileset.fileFilter (file: file.hasExt "md") unfilteredSrc) # for `#[doc = include_str!(...)]`
      ];
    };

    strictDeps = true;
    CARGO_PROFILE = "release-lto";

    meta = {
      sourceProvenance = [ lib.sourceTypes.fromSource ];
      license = [
        lib.licenses.asl20
        lib.licenses.mit
      ];
    };
  };
in
craneLib.buildPackage (
  lib.recursiveUpdate args {
    # Build the Cargo dependencies separately so that they can be cached when our source changes.
    cargoArtifacts = craneLib.buildDepsOnly args;
    cargoExtraArgs = "--package change-me-project-name";

    meta = {
      description = "change-me-project-description";
      mainProgram = "change-me-project-name";
    };
  }
)
