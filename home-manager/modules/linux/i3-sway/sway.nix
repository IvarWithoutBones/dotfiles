{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./config
    ../tofi.nix
  ];

  wayland = {
    systemd.target = "sway-session.target";

    windowManager.sway = {
      enable = true;

      # Set environment variables needed for GTK programs in the wrapper
      wrapperFeatures.gtk = true;

      # Create a systemd target (`sway-session.target`) so that other services can start after it
      systemd = {
        enable = true;
        xdgAutostart = true;
      };

      extraSessionCommands = ''
        # Disable hardware cursors to fix the cursor sometimes disappearing
        export WLR_NO_HARDWARE_CURSORS=1

        # Fixes rendering issues in Java AWT applications (e.g. Ghidra)
        export _JAVA_AWT_WM_NONREPARENTING=1

        # Use the Wayland backend for Firefox
        export MOZ_ENABLE_WAYLAND=1

        # Use the Wayland backend for SDL applications
        export SDL_VIDEODRIVER=wayland

        # Use the Wayland backend for QT applications
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      ''
      # Set statically configured QT theming environment variables so that programs launched through sway inherit them.
      + lib.optionalString (config.home.sessionVariables ? "QT_STYLE_OVERRIDE") ''
        export QT_STYLE_OVERRIDE=${config.home.sessionVariables.QT_STYLE_OVERRIDE}
      ''
      + lib.optionalString (config.home.sessionVariables ? "QT_QPA_PLATFORMTHEME") ''
        export QT_QPA_PLATFORMTHEME=${config.home.sessionVariables.QT_QPA_PLATFORMTHEME}
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

  xdg = {
    mimeApps.defaultApplications = lib.mkIf config.xdg.mimeApps.enable {
      "inode/directory" = "nautilus.desktop";
      "image/svg+xml" = "org.gnome.Loupe.desktop";
      "image/png" = "org.gnome.Loupe.desktop";
      "image/jpeg" = "org.gnome.Loupe.desktop";
      "image/jpg" = "org.gnome.Loupe.desktop";
    };

    # Use xdg-desktop-portal-wlr for screen sharing and screenshots
    portal = lib.mkIf config.xdg.portal.enable {
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
      config.sway = lib.mkAfter config.xdg.portal.config.common // {
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      };
    };

    # Allow the user to select a monitor or window to share when using the screencast portal
    configFile."xdg-desktop-portal-wlr/sway" = lib.mkIf config.xdg.portal.enable {
      text = lib.generators.toINI { } {
        screencast = {
          chooser_type = "simple";
          chooser_cmd = pkgs.writeShellScript "xdg-desktop-portal-wlr-sway-chooser" ''
            set -euo pipefail

            # Output is "<monitor> <monitor | window id>"
            PICKED="$(${lib.getExe' config.wayland.windowManager.sway.package "swaymsg"} -t get_tree \
                | ${lib.getExe pkgs.jq} -r '.. | select(.pid? and .visible?) |
                  "\(.rect.x+.window_rect.x),\(.rect.y+.window_rect.y) \(.window_rect.width)x\(.window_rect.height) \(.foreign_toplevel_identifier)"' \
                | ${lib.getExe pkgs.slurp} -o -r -f '%o %l')"

            MONITOR="$(${lib.getExe' pkgs.coreutils "cut"} -d ' ' -f 1 <<< "$PICKED")"
            OUTPUT="$(${lib.getExe' pkgs.coreutils "cut"} -d ' ' -f 2 <<< "$PICKED")"
            [[ "$MONITOR" == "$OUTPUT" ]] && echo "Monitor: $OUTPUT" || echo "Window: $OUTPUT"
          '';
        };
      };
    };
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
