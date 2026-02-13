{
  createScript,
  coreutils,
  binutils,
}:

createScript "readalias" ./read-macos-alias.sh {
  dependencies = [
    coreutils
    binutils
  ];

  meta.description = "Print the path a MacOS alias file links to";
}
