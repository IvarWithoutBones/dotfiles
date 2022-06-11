{ config
, pkgs
, lib
, gpu
, ...
}:

{
  programs = {
    steam.enable = true;
    dconf.enable = true;
  };

  services = {
    xserver = {
      # On AMD we use wayland
      enable = lib.mkIf (gpu != "amd") true;

      libinput = {
        enable = true;
        touchpad = {
          tapping = false;
          naturalScrolling = true;
          accelProfile = "flat";
        };
      };

      displayManager = {
        lightdm.enable = !(config.services.greetd.enable);
        startx.enable = config.services.xserver.enable; # Required for greetd, it doesn't start the xserver
      };

      # A session for whatever desktop environment is configured in home-manager, for both xorg and wayland.
      desktopManager.session = [{
        name = "home-manager";
        start = ''
          ${pkgs.runtimeShell} ${lib.optionalString config.services.xserver.displayManager.startx.enable "startx"} $HOME/.hm-graphical-session &
          waitPID=$!
        '';
      }];
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

  # Without this swaylock cannot authenticate the user
  security.pam.services.swaylock = lib.mkIf (gpu == "amd") {};
}
