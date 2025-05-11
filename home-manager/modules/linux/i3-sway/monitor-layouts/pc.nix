{ lib
, pkgs
, ...
}:

{
  # Set the correct monitor layout after starting the graphical session, for my desktop machine
  systemd.user.services.monitor-layout = {
    Unit = {
      Description = "Monitor Layout";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install.WantedBy = [ "graphical-session.target" ];
    Service.ExecStart = "${lib.getExe pkgs.xorg.xrandr} --output DVI-D-0 --off --output HDMI-0 --mode 2560x1440 --pos 0x0 --rotate normal --output HDMI-1 --primary --mode 3440x1440 --pos 2560x0 --rotate normal --output DP-0 --off --output DP-1 --off --output DP-2 --off --output DP-3 --off";
  };
}
