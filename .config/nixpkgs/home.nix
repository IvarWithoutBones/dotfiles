{ config, pkgs, ... }:
let
  vimsettings = import ./nvim.nix;
  qutesettings = import ./qutebrowser.nix;
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Utils required by dotfiles
    xorg.xmodmap xorg.xprop
    nitrogen
    sysstat
    maim
    xclip
    dunst
    feh
    imagemagick
    speedtest-cli
    redshift
    perl

    # General utils
    unar unzip
    cmake gnumake
    wget
    git
    htop
    neofetch
    tree

    # Nix specific utils
    nix-index
    nix-prefetch-git
    appimage-run

    # Python38 libraries
    (python38.withPackages (pkgs: with pkgs; [
      setuptools
      dbus-python
    ]))

    # Games
    snes9x-gtk mupen64plus dolphinEmu
    steam

    # Media
    kdenlive obs-studio
    ncspot alacritty
    playerctl
    spotify
    firefox
    tor-browser-bundle-bin
    mpv
    ffmpeg

    # Applications
    _1password
    pavucontrol
    lxappearance
    arc-theme
    arc-icon-theme
    discord
    transmission-gtk
    pentablet-driver
  ];

  programs = {
    neovim = vimsettings pkgs;
    qutebrowser = qutesettings;
  };

  home.stateVersion = "20.09";
}
