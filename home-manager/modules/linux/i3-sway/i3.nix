{ pkgs, ... }:

{
  imports = [ ./config ];
  xsession.windowManager.i3.enable = true;

  home.packages = [
    pkgs.arandr
    # TODO: Re-enable once the following PR is makes it into my channel: https://github.com/NixOS/nixpkgs/pull/438729
    # pkgs.i3-swallow
  ];
}
