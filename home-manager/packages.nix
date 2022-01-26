{ pkgs, config, ... }:
let
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { inherit pkgs; };
in {
  home.packages = with pkgs; [
    arc-theme capitaine-cursors arc-icon-theme
    twitter-color-emoji
    
    # General utils
    alacritty
    htop
    ripgrep
    wget git
    unar
    neofetch
    tree
    bat
    feh
    python3
    file
  
    # Nix specific utils
    nix-index
    nix-prefetch-git
    cachix
    comma
  
    # Media
    ncspot spotify
    mpv
  
    # Applications
    krita
    _1password-gui
    discord
    pavucontrol
    transmission-gtk
  
    # Emulators/games
    dolphinEmuMaster
    citra
    lutris # for cemu
    #nur.repos.ivar.ryujinx
    #nur.repos.ivar.yuzu-ea
    steam
    minecraft
  ]; 
}
