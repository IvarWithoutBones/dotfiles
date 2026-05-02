{ pkgs, ... }:

{
  environment = {
    # links paths from derivations to /run/current-system/sw
    pathsToLink = [
      "/libexec"
      "/share/zsh"
      "/share/fish"
      "/share/bash-completion"
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];

    systemPackages = with pkgs; [
      neovim
      git
    ];
  };

  time.timeZone = "Europe/Amsterdam";
  programs.zsh.enable = true;

  services.fstrim.enable = true;
}
