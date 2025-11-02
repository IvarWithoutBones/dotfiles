{ pkgs
, ...
}:

{
  imports = [ ./config ];
  xsession.windowManager.i3.enable = true;

  home.packages = with pkgs; [
    arandr
    i3-swallow
    xclip
  ];
}
