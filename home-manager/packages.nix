{ pkgs, config, ... }:

let
  dotfiles-tool = pkgs.runCommand "dotfiles-tool" {
    src = ../scripts/dotfiles.sh;
  } ''
    mkdir -p $out/bin
    install -Dm755 $src $out/bin/dotfiles
  '';

  nixpkgs-pr = pkgs.runCommand "nixpkgs-pr" {
    src = pkgs.substituteAll {
      src = ../scripts/nixpkgs-pr.sh;
      binPath = with pkgs; lib.makeBinPath [
        nix
        curl
        git
        pandoc
        gnused
        pandoc
        jq
        coreutils
        python3
        curl
        xdg_utils
      ];
      inherit (pkgs) runtimeShell;
    };
  } ''
    mkdir -p $out/bin
    install -Dm755 $src $out/bin/nixpkgs-pr
  '';
in {
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
    steam
    minecraft
  ]; 
}
