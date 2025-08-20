{ config
, pkgs
, lib
, wayland
, ...
}:

{
  # Required for some GTK programs.
  programs.dconf.enable = true;

  services = {
    xserver = {
      enable = !wayland;
      enableTearFree = true; # Reduce screen tearing.

      desktopManager = {
        # Run XDG autostart entries.
        runXdgAutostartIfNone = true;

        # A session that simply starts whatever is configured in home-manager. Works both with Wayland and X11.
        session = [{
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} "$HOME"/.hm-graphical-session &
            waitPID=$!
          '';
        }];
      };

      # Required when using Xorg as greetd cannot start the xserver on its own.
      displayManager.startx.enable = config.services.xserver.enable;
    };

    # Desktop manager
    greetd = {
      enable = true;
      useTextGreeter = true; # Don't show console messages while the tuigreet is active.

      settings = {
        default_session.command =
          let
            desktopSessions = "${config.services.displayManager.sessionData.desktops}/share";
          in
          ''
            ${lib.getExe pkgs.tuigreet} \
              --sessions ${desktopSessions}/wayland-sessions \
              --xsessions ${desktopSessions}/xsessions \
              --time \
              --asterisks \
              --user-menu \
              --remember \
              --remember-session
          '';
      };
    };
  };
}
