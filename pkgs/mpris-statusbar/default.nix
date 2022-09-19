{ createScript
, playerctl
, coreutils
}:

createScript "mpris-statusbar" ./mpris-statusbar.sh {
  dependencies = [
    playerctl
    coreutils
  ];

  meta.description = "Display the currently playing song according to MPRIS, used by my status bar";
}
