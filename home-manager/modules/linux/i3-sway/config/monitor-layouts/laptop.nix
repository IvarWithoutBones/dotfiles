{ config
, lib
, pkgs
, ...
}:

# Set the correct monitor layout for this computer after starting the graphical session.
# TODO: Make this a module so that we can share the implementation with `pc.nix`.

let
  outputs = {
    DP-1 = {
      pos = { x = 0; y = 0; };
      res = "1920x1080";
      refreshRate = 60;
      scale = 1.0;
    };

    DP-3 = {
      pos = { x = 1920; y = 0; };
      res = "1920x1080";
      refreshRate = 60;
      scale = 1.0;
    };

    eDP-2 = {
      pos = { x = 3840; y = 180; };
      res = "2880x1800";
      refreshRate = 60;
      scale = 2.0;
    };
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
          (name: attrs:
            let
              pos = "${toString attrs.pos.x}x${toString attrs.pos.y}";
              scale = "${toString attrs.scale}x${toString attrs.scale}";
            in
            "--output ${name} --mode ${attrs.res} --pos ${pos} --rate ${toString attrs.refreshRate} --scale ${scale}"
          )
          outputs;
      in
      "${lib.getExe pkgs.xorg.xrandr} ${lib.concatStringsSep " " args}";
  };

  # With Sway we configure it using the home-manager module.
  wayland.windowManager.sway.extraConfig =
    let
      args = lib.mapAttrsToList
        (name: attrs:
          let
            resolution = "${attrs.res}@${toString attrs.refreshRate}Hz";
          in
          "output ${name} position ${toString attrs.pos.x} ${toString attrs.pos.y} resolution ${resolution} scale ${toString attrs.scale}"
        )
        outputs;
    in
    lib.mkIf config.wayland.windowManager.sway.enable (lib.concatStringsSep "\n" args);
}
