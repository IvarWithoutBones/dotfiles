{ pkgs
, ...
}:

{
  imports = [ ./config ];
  xsession.windowManager.i3.enable = true;

  home.packages = with pkgs; [
    i3-swallow
    arandr
    xclip
    xkill
  ];

  # Automatically disable sleep/lock while apps are playing audio
  services.caffeine.enable = true;

  # Ensure caffeine only starts in X11 sessions. The service is defined by `services.caffeine`.
  systemd.user.services.caffeine.Unit.ConditionEnvironment = "XAUTHORITY";
}
