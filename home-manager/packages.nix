{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
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
    fd
    nix-prefetch-git
    comma
    manix

    # Packages from my overlay
    dotfiles-tool
    nixpkgs-pr
    nix-search-fzf
    mkscript
    cat-command
    callpackage-cli
    copy-nix-derivation
  ] ++ lib.optionals pkgs.stdenvNoCC.isLinux [
    # Package from my overlay
    speedtest

    # Fonts. TODO: manage this from a module option?
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    gnome.ghex
    i3-swallow
    ncspot
    spotify
    krita
    _1password-gui
    transmission-gtk
    citra
    minecraft
  ];
}
