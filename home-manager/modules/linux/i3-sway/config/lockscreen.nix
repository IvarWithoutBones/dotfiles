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

  services.swayidle =
    let
      theme = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/swaylock/17aa0be6ae7a166256c3d6d6de643b0b49c865dd/themes/mocha.conf";
        hash = "sha256-y4Y+qZQEpMAmhT4dKHY+ZumfWfKvVvjWHyqhafdakF8=";
      };

      settings = [
        # Use the theme specified above with a blurred background and the indicator.
        "--config=${theme}"
        "--screenshots"
        "--indicator"
        "--indicator-caps-lock"
        "--clock"
        "--effect-scale=0.25" # Scale down to speed up the blur effect.
        "--effect-blur=4x4"
        "--effect-scale=1" # Scale back to original size.
        # Don't require a password to unlock for the first N settings.
        "--grace=5"
        "--grace-no-mouse"
        "--grace-no-touch"
      ];

      command = "${lib.getExe pkgs.swaylock-effects} --daemonize ${lib.concatStringsSep " " settings}";
      swaymsg = lib.getExe' config.wayland.windowManager.sway.package "swaymsg";
    in
    lib.mkIf config.wayland.windowManager.sway.enable {
      enable = true;
      systemdTarget = "sway-session.target"; # Only start when the sway session is active.

      timeouts = [
        { inherit timeout command; } # Go to sleep after N seconds.
        {
          # After another N seconds, turn off all displays.
          timeout = timeout * 2;
          command = "${swaymsg} 'output * dpms off'";
          resumeCommand = "${swaymsg} 'output * dpms on'";
        }
      ];

      # Run the lock command before going to sleep via systemd-suspend/logind.
      events = [
        { event = "before-sleep"; inherit command; }
        { event = "lock"; inherit command; }
      ];
    };
}
