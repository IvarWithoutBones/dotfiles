{ pkgs, ... }:

{
  imports = [ ./config ];
  xsession.windowManager.i3.enable = true;

  home.packages = [
    pkgs.i3-swallow
    pkgs.arandr
  ];
}
