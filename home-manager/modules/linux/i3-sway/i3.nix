{ pkgs
, ...
}:

{
  imports = [ ./config ];
  xsession.windowManager.i3.enable = true;

  home.packages = with pkgs; [
    i3-swallow # Replace terminal windows when launching GUI apps
    arandr # Display configuration
    xclip # Clipboard utilities
    xkill # Kill applications by clicking on their window
    feh # Image viewer
  ];

  # Automatically disable sleep/lock while apps are playing audio
  services.caffeine.enable = true;

  # Ensure caffeine only starts in X11 sessions. The service is defined by `services.caffeine`.
  systemd.user.services.caffeine.Unit.ConditionEnvironment = "XAUTHORITY";
}
