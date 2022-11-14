{ pkgs
, config
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
    Service.ExecStart = "${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-0 --mode 1280x1024 --pos 0x0 --rotate normal --output DP-2 --primary --mode 3440x1440 --pos 1280x0 --rotate normal";
  };
}
