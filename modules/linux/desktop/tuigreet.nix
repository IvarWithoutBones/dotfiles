{ config
, pkgs
, lib
, ...
}:

{
  services = {
    # Required for tuigreet to start X11 sessions.
    xserver.displayManager.startx.enable = config.services.xserver.enable;

    # Configure tuigreet as the default greetd greeter.
    greetd = {
      enable = true;
      useTextGreeter = true; # Don't show console messages while the tuigreet is active.
      settings.default_session.command =
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
}
