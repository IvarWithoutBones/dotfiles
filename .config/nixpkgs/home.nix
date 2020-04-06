{ config, pkgs, ... }:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    xorg.xmodmap
    xorg.xprop
    neovim
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
    qutebrowser
    tor-browser-bundle-bin
    mpv
    discord
    spotify
    appimage-run
    transmission-gtk
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
  ];

  programs.neovim = {
    viAlias = true;
    vimAlias = true;
    extraPython3Packages = [
      pkgs.python38Packages.jedi # Does not work for some reason?
    ];
  };

  home.stateVersion = "20.03";
}
