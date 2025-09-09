{ lib
, pkgs
, ...
}:

{
  imports = [ ./config ];
  wayland.windowManager.sway.enable = true;

  home.packages = [
    pkgs.wdisplays
  ];

  systemd.user.services.sway-audio-idle-inhibit = {
    Unit = {
      Description = "Prevent going to sleep or locking the screen while audio is playing";
      PartOf = [ "sway-session.target" ];
      After = [ "sway-session.target" ];
    };

    Service = {
      Type = "exec";
      Restart = "always";
      ExecStart = lib.getExe pkgs.sway-audio-idle-inhibit;
    };

    Install.WantedBy = [ "sway-session.target" ];
  };
}
