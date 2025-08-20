{ config
, lib
, pkgs
, ...
}:

# Set the correct monitor layout for this computer after starting the graphical session.

let
  outputs = {
    HDMI-0 = { res = "2560x1440"; pos = { x = 0; y = 0; }; };
    HDMI-1 = { res = "3440x1440"; pos = { x = 2560; y = 0; }; };
  };

  swayOutputNames = {
    HDMI-0 = "HDMI-A-1";
    HDMI-1 = "HDMI-A-2";
  };
in
{
  # On X11 we use xrandr in a systemd service that runs after the graphical session starts up.
  systemd.user.services.monitor-layout = lib.mkIf config.xsession.enable {
    Unit = {
      Description = "Monitor Layout";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install.WantedBy = [ "graphical-session.target" ];
    Service.ExecStart =
      let
        args = lib.mapAttrsToList
          (name: attrs: "--output ${name} --mode ${attrs.res} --pos ${toString attrs.pos.x}x${toString attrs.pos.y}")
          outputs;
      in
      "${lib.getExe pkgs.xorg.xrandr} ${lib.concatStringsSep " " args}";
  };

  # With Sway we configure it using the home-manager module.
  wayland.windowManager.sway.extraConfig =
    let
      args = lib.mapAttrsToList
        (name: attrs: "output ${swayOutputNames.${name}} pos ${toString attrs.pos.x} ${toString attrs.pos.y} res ${attrs.res}")
        outputs;
    in
    lib.mkIf config.wayland.windowManager.sway.enable (lib.concatStringsSep "\n" args);
}
