{ config
, lib
, pkgs
, ...
}:

# Configuration for adjusting display color temperature of the display based on the surrounding light.

let
  cfg = {
    latitude = "52.1";
    longitude = "5.2";
    temperature = {
      night = 3000;
      day = 6500;
    };
  };
in
{
  # We only use gammastep in X11 sessions, as unfortunately it requires us to statically configure
  # if we want it to use its X11 or Wayland backend. We need it to be dynamic based on the session.
  services.gammastep = lib.mkIf config.xsession.enable {
    enable = true;
    inherit (cfg) latitude longitude temperature;
    settings.general.adjustment-method = "randr";
  };

  # Ensure the gammastep service only starts in X11 sessions. The service is defined by `services.gammastep`.
  systemd.user.services.gammastep.Unit.ConditionEnvironment = "XAUTHORITY";

  # Use wlsunset for Wayland sessions.
  systemd.user.services.wlsunset = lib.mkIf config.wayland.windowManager.sway.enable {
    Install.WantedBy = [ "sway-session.target" ];
    Unit = {
      Description = "Set the screen color temperature based on surrounding light";
      PartOf = [ "sway-session.target" ];
      After = [ "sway-session.target" ];
    };

    Service = {
      Type = "exec";
      Restart = "on-failure";
      ExecStart = "${lib.getExe pkgs.wlsunset} -l ${cfg.latitude} -L ${cfg.longitude} -t ${toString cfg.temperature.night} -T ${toString cfg.temperature.day}";
    };
  };
}
