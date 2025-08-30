{ config
, lib
, pkgs
, ...
}:

# Used in conjunction with `modules/linux/desktop/lockscreen.nix`.

{
  services.screen-locker = lib.mkIf config.xsession.windowManager.i3.enable {
    enable = true;
    lockCmd = lib.getExe pkgs.i3lock-fancy;
    inactiveInterval = 2; # In minutes
  };

  services.swayidle =
    let
      command = lib.getExe pkgs.swaylock-fancy;
    in
    lib.mkIf config.wayland.windowManager.sway.enable {
      enable = true;

      events = [{
        event = "before-sleep";
        inherit command;
      }];

      timeouts = [{
        timeout = 120; # In seconds
        inherit command;
      }];
    };
}
