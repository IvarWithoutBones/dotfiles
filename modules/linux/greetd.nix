{ config
, pkgs
, lib
, wayland
, ...
}:

{
  # Required for some GTK programs.
  programs.dconf.enable = true;

  # Allow swaylock to authenticate the user.
  security.pam.services.swaylock = lib.mkIf wayland { };

  services = {
    xserver = {
      enable = !wayland;

      # A session for whatever desktop environment is configured in home-manager, for both xorg and wayland.
      desktopManager = {
        xterm.enable = false; # Otherwise we get a non-functional desktop session in the closure.
        session = [{
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} ${lib.optionalString config.services.xserver.displayManager.startx.enable "startx"} $HOME/.hm-graphical-session &
            waitPID=$!
          '';
        }];
      };

      displayManager = {
        # Required when using Xorg as greetd cannot start the xserver on its own.
        startx.enable = config.services.xserver.enable;
        lightdm.enable = false;
      };
    };

    # Desktop manager
    greetd = {
      enable = true;
      vt = config.services.xserver.tty;

      settings = {
        default_session.command =
          let
            sessions = "${config.services.displayManager.sessionData.desktops}/share/xsessions";
          in
          "${pkgs.greetd.tuigreet}/bin/tuigreet --sessions \"${sessions}\" --time --asterisks --user-menu --remember --remember-session";
      };
    };
  };
}
