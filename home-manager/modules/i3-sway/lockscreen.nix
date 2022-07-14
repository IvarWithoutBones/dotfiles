{ config
, lib
, pkgs
, wayland
, ...
}:

lib.optionalAttrs wayland {
  services.swayidle =
    let
      command = "${pkgs.swaylock-fancy}/bin/swaylock-fancy";
    in
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
          timeout = 120;
          inherit command;
        }
      ];
    };
}
