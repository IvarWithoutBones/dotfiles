{ pkgs, ... }: {

home.packages = with pkgs; [
  sysstat
  perl
  dconf # Required for some GTK based app's settings to be saved
  
  # General utils
  st
  htop gotop
  wget git
  unar
  neofetch
  tree
  bat
  feh

  # Nix specific utils
  nix-index
  nix-prefetch-git
  direnv

  # Media
  ncspot spotify apple-music-electron
  mpv

  # Applications
  minecraft
  _2048-in-terminal
  steam
  _1password-gui
  discord
  dolphinEmu
  pavucontrol
  arc-theme capitaine-cursors arc-icon-theme
  transmission-gtk
]; }
