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

      timeouts = [{ inherit timeout command; }];
    };
}
