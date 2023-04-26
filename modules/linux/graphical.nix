{ config
, pkgs
, lib
, wayland
, ...
}:

{
  programs = {
    # Required for some GTK prorams
    dconf.enable = true;
  };

  # Without this swaylock cannot authenticate the user
  security.pam.services.swaylock = lib.mkIf wayland { };

  services = {
    gnome.gnome-keyring.enable = true;

    xserver = {
      enable = !(wayland);

      libinput = {
        enable = true;
        touchpad = {
          tapping = false;
          naturalScrolling = true;
          accelProfile = "flat";
        };
      };

      # A session for whatever desktop environment is configured in home-manager, for both xorg and wayland.
      desktopManager = {
        xterm.enable = false; # Otherwise we get a non-functional desktop session in the closure
        session = [{
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} ${lib.optionalString config.services.xserver.displayManager.startx.enable "startx"} $HOME/.hm-graphical-session &
            waitPID=$!
          '';
        }];
      };

      displayManager = {
        lightdm.enable = !(config.services.greetd.enable);
        startx.enable = config.services.xserver.enable; # Required for greetd, it doesn't start the xserver
      };
    };

    # Desktop manager
    greetd = {
      enable = true;
      vt = config.services.xserver.tty;

      settings = {
        default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --sessions \"${config.services.xserver.displayManager.sessionData.desktops}/share/xsessions\" --time";
      };
    };
  };
}
