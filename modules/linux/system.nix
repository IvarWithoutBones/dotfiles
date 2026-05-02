{ pkgs, ... }:

{
  environment = {
    # links paths from derivations to /run/current-system/sw
    pathsToLink = [
      "/libexec"
      "/share/man"
      "/share/applications"
      "/share/xdg-desktop-portal"
      "/share/zsh"
      "/share/fish"
      "/share/bash-completion"
    ];

    systemPackages = with pkgs; [
      neovim
      git
    ];
  };

  programs.zsh.enable = true;
  services.fstrim.enable = true;
  time.timeZone = "Europe/Amsterdam";
}
