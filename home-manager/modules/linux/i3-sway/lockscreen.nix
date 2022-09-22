{ config
, lib
, pkgs
, wayland
, ...
}:

{
  services.screen-locker = lib.optionalAttrs (!wayland) {
    # TODO: this does not do anything if my laptops lid gets closed. I use wayland on there though, so doesnt really matter
    enable = true;
    lockCmd = "${pkgs.i3lock-fancy}/bin/i3lock-fancy";
    inactiveInterval = 2; # In minutes
  };

  services.swayidle =
    let
      command = "${pkgs.swaylock-fancy}/bin/swaylock-fancy";
    in
    lib.optionalAttrs wayland
      {
        enable = true;

        events = [
          {
            event = "before-sleep";
            inherit command;
          }
        ];

        timeouts = [
          {
            timeout = 120; # In seconds
            inherit command;
          }
        ];
      };
}
