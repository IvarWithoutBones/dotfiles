{ pkgs
, ...
}:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    extest.enable = true; # Translate X11 input events to uinput events.
    gamescopeSession.enable = true; # Enable the gamescope display session.

    package = pkgs.steam.override {
      extraPkgs = pkgs: [
        pkgs.er-patcher # Elden Ring enhancement patches.
      ];
    };

    extraCompatPackages = [
      pkgs.proton-ge-bin # A fork of Proton that sometimes has better compatibility.
    ];
  };
}
