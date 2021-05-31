{ pkgs, ... }:
let
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { inherit pkgs; };
in {
home.packages = with pkgs; [
  arc-theme capitaine-cursors arc-icon-theme
  twitter-color-emoji
  
  # General utils
  st
  htop gotop
  wget git
  unar
  neofetch
  tree
  bat
  feh
  python3Minimal

  # Nix specific utils
  nix-index
  nix-prefetch-git
  direnv
  cachix

  # Media
  ncspot spotify apple-music-electron
  mpv

  # Applications
  _1password-gui
  discord
  pavucontrol
  transmission-gtk

  # Emulators/games
  dolphinEmuMaster
  snes9x-gtk
#  nur.repos.ivar.ryujinx
#  nur.repos.ivar.yuzu-ea
  lutris # for cemu
  steam
  minecraft
  _2048-in-terminal
]; }
