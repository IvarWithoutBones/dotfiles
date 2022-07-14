{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # Fonts
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    git
    github-cli
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
    fd
    nix-index
    nix-prefetch-git
    comma
    manix
    dotfiles-tool
    nixpkgs-pr
    nix-search-fzf
    alacritty
    pavucontrol
    i3-swallow
    ncspot spotify
    krita
    _1password-gui
    transmission-gtk
    citra
    minecraft
  ]; 
}
