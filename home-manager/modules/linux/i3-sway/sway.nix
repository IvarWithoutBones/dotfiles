{ config
, lib
, pkgs
, ...
}:

{
  imports = [ ./config ];
  wayland.windowManager.sway.enable = true;

  home.packages = with pkgs; [
    wdisplays # Display configuration
    wl-clipboard # Clipboard utilities
    nautilus # File manager
    loupe # Image viewer
  ];

  xdg.mimeApps.defaultApplications = lib.mkIf config.xdg.mimeApps.enable {
    "inode/directory" = "nautilus.desktop";
    "image/svg+xml" = "org.gnome.Loupe.desktop";
    "image/png" = "org.gnome.Loupe.desktop";
    "image/jpeg" = "org.gnome.Loupe.desktop";
    "image/jpg" = "org.gnome.Loupe.desktop";
  };

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
