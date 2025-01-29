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
    Service.ExecStart = "${lib.getExe pkgs.xorg.xrandr} --output DP-0 --primary --mode 3440x1440 --pos 1280x0 --rotate normal";
  };
}
