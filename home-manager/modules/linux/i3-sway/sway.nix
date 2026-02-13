{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./config ];

  wayland = {
    systemd.target = "sway-session.target";

    windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;

      # Create a systemd target (`sway-session.target`) so that other services can start after it
      systemd = {
        enable = true;
        xdgAutostart = true;
      };

      extraSessionCommands = ''
        # Disable hardware cursors to fix the cursor sometimes disappearing
        export WLR_NO_HARDWARE_CURSORS=1

        # Use the Wayland backend for SDL applications
        export SDL_VIDEODRIVER=wayland

        # Use the Wayland backend for QT applications
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"

        # Fixes rendering issues in Java AWT applications (e.g. Ghidra)
        export _JAVA_AWT_WM_NONREPARENTING=1

        # Use the Wayland backend for Firefox
        export MOZ_ENABLE_WAYLAND=1
      '';
    };
  };

  home.packages = with pkgs; [
    wdisplays # Display configuration
    wl-clipboard # Clipboard utilities
    waypipe # Graphical application forwarding over SSH
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

  systemd.user.services.wayland-pipewire-idle-inhibit =
    let
      configFile = (pkgs.formats.toml { }).generate "wayland-pipewire-idle-inhibit.toml" {
        media_minimum_duration = 5;
        idle_inhibitor = "wayland";
      };
    in
    {
      Unit = {
        Description = "Inhibit Wayland idling when media is played through pipewire";
        Documentation = "https://github.com/rafaelrc7/wayland-pipewire-idle-inhibit";
        PartOf = [ config.wayland.systemd.target ];
        After = [
          config.wayland.systemd.target
          "pipewire.service"
          "pipewire-pulse.service"
        ];
        Wants = [
          "pipewire.service"
          "pipewire-pulse.service"
        ];
      };

      Service = {
        Type = "exec";
        Restart = "always";
        RestartSec = 10;
        ExecStart = "${lib.getExe pkgs.wayland-pipewire-idle-inhibit} --config ${configFile}";
      };

      Install.WantedBy = [ config.wayland.systemd.target ];
    };
}
