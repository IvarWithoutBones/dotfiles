{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
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

    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    # Nix specific utils
    nix-index
    nix-prefetch-git
    comma
    manix

    # custom tools
    dotfiles-tool
    nixpkgs-pr
  
    # Graphical utils
    alacritty
    pavucontrol
    i3-swallow

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
    minecraft
  ]; 
}
