{
  # From the flake
  flake-check-pre-commit,
  change-me-project-name,
  # From nixpkgs
  stdenv,
  lib,
  mkShell,

  # Whether or not to install pre-commit hooks
  withPreCommit ? true,
}:

mkShell {
  inputsFrom = [
    change-me-project-name
  ];

  nativeBuildInputs = lib.optionals withPreCommit flake-check-pre-commit.enabledPackages;
  shellHook = lib.optionalString withPreCommit flake-check-pre-commit.shellHook;

  env = {
    # Set the default target and linker for Cargo in case we're cross-compiling.
    CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTarget;
    "CARGO_TARGET_${stdenv.hostPlatform.rust.cargoEnvVarTarget}_LINKER" = lib.getExe stdenv.cc;

    # Ensure crane's setup hooks dont influence `nix-shell` (issue with flake-compat).
    doNotPostBuildInstallCargoBinaries = true;
  };
}
