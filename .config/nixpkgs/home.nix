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
    obs-studio
    alacritty
    _1password
    thunderbird
    xorg.xmodmap
    xorg.xprop
    wget
    git
    htop
    sysstat
    unzip
    maim
    xclip
    dunst
    clipit
    networkmanagerapplet
    feh
    pavucontrol
    imagemagick
    firefox
    lxappearance
    arc-theme
    arc-icon-theme
    tree
    nitrogen
    binutils
    coreutils
    file
    cmake
    gnumake
    redshift
    playerctl
    perl
    speedtest-cli
    tor-browser-bundle-bin
    mpv
    discord
    spotify
    appimage-run
    transmission-gtk
    xp-pen-g430
    steam
    snes9x-gtk
    mupen64plus
    dolphinEmu
    nix-index
    nix-prefetch-git
    ffmpeg
    neofetch
    gdb
    (python38.withPackages (pkgs: with pkgs; [ setuptools dbus-python ]))
    ncspot
  ];

  programs.neovim = vimsettings pkgs;
  programs.qutebrowser = qutesettings;

  home.stateVersion = "20.03";
}
