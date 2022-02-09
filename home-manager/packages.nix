{ pkgs, config, ... }:

let
  dotfiles-tool = pkgs.runCommand "dotfiles-tool" {
    src = ../scripts/dotfiles.sh;
  } ''
    mkdir -p $out/bin
    install -Dm755 $src $out/bin/dotfiles
  '';
in {
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
    dotfiles-tool
  
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
