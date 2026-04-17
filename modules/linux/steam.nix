{
  pkgs,
  ...
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

  # Allow userspace to create virtual input devices, used for some games
  hardware.uinput.enable = true;

  # Make SDL applications support more controllers.
  environment.sessionVariables.SDL_GAMECONTROLLERCONFIG_FILE = "${pkgs.sdl_gamecontrollerdb}/share/gamecontrollers.txt";
}
