{ pkgs, config, ... }:

let
  update-system = pkgs.writeShellScriptBin "update-system" ''
    set -e

    DOTFILES_DIR="${config.home.homeDirectory}/nix/dotfiles"

    while getopts ":lgh" arg; do
      case $arg in
        l)
          DONT_UPDATE=1 ;;
        g)
          DONT_COLLECT_GARBAGE=1 ;;
        h)
          printf "Usage: "$(basename "$0")" [-lg]\n  [-l] Don't update flake\n  [-g] Don't collect garbage\n" && exit 0 ;;
      esac
    done

    runColored() {
      printf "\e[32m\$ "%s"\n\e[0m" "$1"
      $1
    }

    if [ -z "$DONT_UPDATE" ]; then
      pushd "$DOTFILES_DIR" 1>/dev/null
      runColored "nix flake update"
      popd 1>/dev/null
    fi

    runColored "sudo nixos-rebuild switch --impure"

    [[ -z "$DONT_COLLECT_GARBAGE" ]] && runColored "nix-collect-garbage"
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
    update-system
  
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
