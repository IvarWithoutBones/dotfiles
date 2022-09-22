{ config
, pkgs
, ...
}:

{
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    pinentry-curses
  ];
}
