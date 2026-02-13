{
  config,
  lib,
  pkgs,
  ...
}:

# Used in conjunction with `modules/linux/desktop/lockscreen.nix`.

let
  timeout = 300; # In seconds
  lockKeybinding = modifier: "${modifier}+Shift+x";

  swayCommand =
    let
      colors = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/swaylock/17aa0be6ae7a166256c3d6d6de643b0b49c865dd/themes/mocha.conf";
        hash = "sha256-y4Y+qZQEpMAmhT4dKHY+ZumfWfKvVvjWHyqhafdakF8=";
      };

      options = [
        # Required for the effects to apply correctly.
        "--daemonize"

        # Theming
        "--config=${colors}"
        "--screenshots"
        "--indicator"
        "--indicator-caps-lock"
        "--clock"

        # Blur the background screenshot by first scaling it down to improve performance, blurring it, then restoring it to full size.
        "--effect-scale=0.25"
        "--effect-blur=4x4"
        "--effect-scale=1"

        # Don't require a password to unlock for the first N settings.
        "--grace=5"
        "--grace-no-mouse"
        "--grace-no-touch"
      ];
    in
    "${lib.getExe pkgs.swaylock-effects} ${lib.concatStringsSep " " options}";
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

  xsession.windowManager.i3.config.keybindings = lib.mkIf config.xsession.windowManager.i3.enable {
    ${lockKeybinding config.xsession.windowManager.i3.config.modifier} =
      "exec ${lib.getExe pkgs.i3lock-fancy}";
  };

  services.swayidle =
    let
      swaymsg = lib.getExe' config.wayland.windowManager.sway.package "swaymsg";
    in
    lib.mkIf config.wayland.windowManager.sway.enable {
      enable = true;
      systemdTarget = "sway-session.target"; # Only start when the sway session is active.

      timeouts = [
        {
          inherit timeout;
          command = swayCommand;
        } # Go to sleep after N seconds.
        {
          # After another N seconds, turn off all displays.
          timeout = timeout * 2;
          command = "${swaymsg} 'output * dpms off'";
          resumeCommand = "${swaymsg} 'output * dpms on'";
        }
      ];

      # Run the lock command before going to sleep via systemd-suspend/logind.
      events = {
        before-sleep = swayCommand;
        lock = swayCommand;
      };
    };

  wayland.windowManager.sway.config.keybindings = lib.mkIf config.wayland.windowManager.sway.enable {
    ${lockKeybinding config.wayland.windowManager.sway.config.modifier} = "exec ${swayCommand}";
  };
}
