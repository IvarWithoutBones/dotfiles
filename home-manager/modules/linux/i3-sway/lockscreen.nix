{ lib
, pkgs
, wayland
, ...
}:

# Used in conjunction with `modules/linux/lockscreen.nix`.

{
  services.screen-locker = lib.optionalAttrs (!wayland) {
    enable = true;
    lockCmd = lib.getExe pkgs.i3lock-fancy;
    inactiveInterval = 2; # In minutes
  };

  services.swayidle =
    let
      command = lib.getExe pkgs.swaylock-fancy;
    in
    lib.optionalAttrs wayland {
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
