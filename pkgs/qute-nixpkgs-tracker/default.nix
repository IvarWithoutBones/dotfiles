{ createScript
, gnugrep
, coreutils
}:

createScript "qute-nixpkgs-tracker" ./qute-nixpkgs-tracker.sh {
  dependencies = [
    gnugrep
    coreutils
  ];

  meta.description = "Qutebrowser userscript to open the CI tracker for a nixpkgs PR";
}
