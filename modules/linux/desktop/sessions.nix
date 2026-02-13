{
  config,
  lib,
  pkgs,
  ...
}:

# Register desktop manager sessions that home-manager can define.
# This is required to start up `home-manager/modules/i3-sway/default.nix`.

{
  services = {
    # Register the Wayland session (which forwards to `~/.home-manager-graphical-session-wayland`).
    displayManager.sessionPackages = [
      (
        (pkgs.writeTextDir "share/wayland-sessions/home-manager-wayland.desktop" ''
          [Desktop Entry]
          Version=1.0
          Type=Application
          Name=home-manager-wayland
          DesktopNames=home-manager-wayland
          # Note: we need to wrap this in a shell script to ensure $HOME is expanded.
          Exec=${pkgs.writeShellScript "home-manager-wayland" ''
            ${pkgs.runtimeShell} "$HOME"/.home-manager-graphical-session-wayland
          ''}
        '').overrideAttrs
        (_: {
          passthru.providedSessions = [ "home-manager-wayland" ];
        })
      )
    ];

    # Register the X11 session (which forwards to `~/.home-manager-graphical-session-x11`).
    xserver.desktopManager = lib.mkIf config.services.xserver.enable {
      runXdgAutostartIfNone = true; # Run XDG autostart entries for window managers.
      session = [
        {
          name = "home-manager-x11";
          manage = "window"; # Indicate that we're using a window manager.
          start = ''
            ${pkgs.runtimeShell} "$HOME"/.home-manager-graphical-session-x11 &
            waitPID=$!
          '';
        }
      ];
    };
  };
}
