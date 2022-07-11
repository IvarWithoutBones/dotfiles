{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # Fonts
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

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
    killall
    speedtest
    gnome.ghex
    fzf

    # Nix specific utils
    nix-index
    nix-prefetch-git
    comma
    manix

    # my own tools
    dotfiles-tool
    nixpkgs-pr
    nix-search-fzf
  
    # Graphical utils
    alacritty
    pavucontrol
    i3-swallow

    # Media
    ncspot spotify
  
    # Applications
    krita
    _1password-gui
    transmission-gtk
  
    # Emulators/games
    citra
    minecraft
  ]; 
}
