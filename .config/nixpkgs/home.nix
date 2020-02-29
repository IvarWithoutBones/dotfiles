{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.xorg.xmodmap
    pkgs.xorg.xprop
    pkgs.alacritty
    pkgs.vim
    pkgs.wget
    pkgs.git
    pkgs.htop
    pkgs.sysstat
    pkgs.gdb
    pkgs.clang
    pkgs.unzip
    pkgs.maim
    pkgs.xclip
    pkgs.dunst
    pkgs.clipit
    pkgs.networkmanagerapplet
    pkgs.feh
    pkgs.pavucontrol
    pkgs.imagemagick
    pkgs.firefox
    pkgs.lxappearance
    pkgs.fff
    pkgs.arc-theme
    pkgs.arc-icon-theme
    pkgs.tree
    pkgs.nitrogen
    pkgs.rustup
    pkgs.pkg-config
    pkgs.binutils
    pkgs.coreutils-full
    pkgs.file
    pkgs.cmake
    pkgs.vscode-with-extensions
    pkgs.gnumake
    pkgs.redshift
    pkgs.playerctl
    pkgs.perl
    pkgs.speedtest-cli
    pkgs.qutebrowser
    pkgs.tor-browser-bundle-bin
    pkgs.thefuck
    pkgs.mpv
    pkgs.discord
    pkgs.spotify
    pkgs.appimage-run
    pkgs.transmission-gtk
    pkgs.steam
    pkgs.snes9x-gtk
    pkgs.mupen64plus
    pkgs.nix-index
  ];

  home.stateVersion = "20.03";
}
