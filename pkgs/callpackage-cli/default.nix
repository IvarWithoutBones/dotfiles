{ createScript
, nix
}:

createScript "callpackage" ./callpackage.sh {
  dependencies = [
    nix
  ];

  meta.description = "a shortcut to callPackage from the command line";
}
