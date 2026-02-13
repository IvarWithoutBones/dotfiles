{
  createScript,
  nix,
}:

createScript "copy-nix-derivation" ./copy-nix-derivation.sh {
  dependencies = [
    nix
  ];

  meta.description = "copy a derivation from a flake to a local path";
}
