{ config
, lib
, pkgs
, wayland
, ...
}:

let
  timeoutInterval = 120;
in
{
  services.screen-locker = lib.optionalAttrs (!wayland) {
    # TODO: this does not do anything if my laptops lid gets closed. I use wayland on there though, so doesnt really matter
    enable = true;

    lockCmd = "${pkgs.swaylock-fancy}/bin/swaylock-fancy";
    inactiveInterval = timeoutInterval;
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
            timeout = timeoutInterval;
            inherit command;
          }
        ];
      };
}
