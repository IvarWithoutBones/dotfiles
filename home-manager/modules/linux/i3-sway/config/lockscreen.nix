{ config
, lib
, pkgs
, ...
}:

# Used in conjunction with `modules/linux/desktop/lockscreen.nix`.

let
  timeout = 120; # In seconds
in
{
  services.screen-locker = lib.mkIf config.xsession.windowManager.i3.enable {
    enable = true;
    lockCmd = lib.getExe pkgs.i3lock-fancy;
    inactiveInterval = timeout / 60; # In minutes
  };

  # Both of these services are defined by `services.screen-locker`, they are X11-only.
  # As they bind to `graphical-session.target` they get started even on Wayland sessions,
  # which is not what we want. Add a condition to only start them if X11 is active.
  systemd.user.services = lib.mkIf config.services.screen-locker.enable {
    xss-lock.Unit.ConditionEnvironment = "XAUTHORITY";
    xautolock-session = lib.mkIf config.services.screen-locker.xautolock.enable {
      Unit.ConditionEnvironment = "XAUTHORITY";
    };
  };

  services.swayidle = lib.mkIf config.wayland.windowManager.sway.enable {
    enable = true;

    # Only start when the sway session is active, same idea as above.
    systemdTarget = "sway-session.target";

    timeouts = [{
      command = lib.getExe pkgs.swaylock-fancy;
      inherit timeout;
    }];
  };
}
