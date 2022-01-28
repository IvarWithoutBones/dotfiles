{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    arc-theme
    arc-icon-theme
    capitaine-cursors
    
    # General utils
    wget git
    ripgrep
    htop
    unar
    tree
    bat
    python3
    file
    feh
  
    # Graphical utils
    alacritty
    pavucontrol

    # Nix specific utils
    nix-index
    nix-prefetch-git
    comma
  
    # Media
    ncspot spotify
    mpv
  
    # Applications
    krita
    _1password-gui
    discord
    transmission-gtk
  
    # Emulators/games
    citra
    steam
    minecraft
  ]; 
}
