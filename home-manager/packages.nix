{ pkgs, config, ... }:

let
  # TODO: remove this once https://github.com/NixOS/nixpkgs/pull/160352 gets merged
  i3-swallow = pkgs.python3Packages.callPackage ./modules/i3/swallow.nix { };

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
    steam
    minecraft
  ]; 
}
