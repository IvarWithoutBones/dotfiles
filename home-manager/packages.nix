{ pkgs
, ...
}:

{
  home.packages = with pkgs; [
    github-cli
    wget
    ripgrep
    htop
    unar
    python3
    file
    feh
    jq
    killall
    fd
    nix-prefetch-git
    comma
    manix
    binutils
    act
    element-desktop
    hexyl
    pcalc
    cargo-flamegraph
    exa

    # Packages from my overlay
    dotfiles-tool
    nixpkgs-pr
    nix-search-fzf
    mkscript
    cat-command
    callpackage-cli
    copy-nix-derivation
    read-macos-alias
  ] ++ lib.optionals pkgs.stdenvNoCC.isLinux [
    # Package from my overlay
    speedtest
    sm64ex-practice

    # Fonts. TODO: manage this from a module option?
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    ares
    evince
    gnome.ghex
    i3-swallow
    ncspot
    psst
    krita
    _1password-gui
    transmission-gtk
    citra
    minecraft
    firefox
  ] ++ lib.optional pkgs.stdenvNoCC.isDarwin iterm2;
}
