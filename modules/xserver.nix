{ config
, pkgs
, lib
, ...
}:

{
  programs = {
    steam.enable = true;
    dconf.enable = true;
  };

  services = {
    xserver = {
      enable = true;

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
        startx.enable = config.services.greetd.enable; # Required for greetd, it doesn't start the xserver
      };

      desktopManager.session = [{
        name = "home-manager";
        start = ''
          ${pkgs.runtimeShell} ${lib.optionalString config.services.xserver.displayManager.startx.enable "startx"} $HOME/.hm-xsession &
          waitPID=$!
        '';
      }];
    };

    greetd = {
      enable = true;
      vt = config.services.xserver.tty;

      settings = {
        default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --sessions \"${config.services.xserver.displayManager.sessionData.desktops}/share/xsessions\" --time";
      };
    };
  };
}
