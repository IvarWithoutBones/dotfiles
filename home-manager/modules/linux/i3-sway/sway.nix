{ pkgs, ... }:

{
  imports = [ ./config ];
  wayland.windowManager.sway.enable = true;

  home.packages = [
    pkgs.wdisplays
  ];
}
