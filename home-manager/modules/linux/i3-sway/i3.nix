{ pkgs, ... }:

{
  imports = [ ./config ];
  xsession.windowManager.i3.enable = true;

  home.packages = [
    pkgs.arandr
    pkgs.i3-swallow
  ];
}
