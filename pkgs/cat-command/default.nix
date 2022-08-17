{ createScript
, bat
, coreutils
}:

createScript "cat-command" ./cat-command.sh {
  dependencies = [
    bat
    coreutils
  ];

  meta.description = "a shortcut to print the contents of a shell command";
}
