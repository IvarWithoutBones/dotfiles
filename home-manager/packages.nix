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
    git github-cli
    wget
    ripgrep
    htop
    unar
    tree
    bat
    python3
    file
    feh
    jq
  
    # Nix specific utils
    nix-index
    nix-prefetch-git
    comma
    dotfiles-tool
  
    # Graphical utils
    alacritty
    pavucontrol

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
