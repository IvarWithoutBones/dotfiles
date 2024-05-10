{ pkgs
, lib
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
    eza
    gimp

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
    proton-ge-runner
    signal-desktop

    # Fonts. TODO: manage this from a module option?
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

    obsidian
    ghidra # TODO: enable on Darwin when it isn't broken there anymore.
    vscode-fhs
    arandr
    ares
    evince
    drawio
    imhex
    i3-swallow
    psst
    krita
    _1password-gui
    transmission-gtk
    firefox
  ] ++ lib.optional pkgs.stdenvNoCC.isDarwin iterm2;

  xdg = lib.mkIf pkgs.stdenvNoCC.isLinux {
    enable = true;

    # Avoid activation failures when the mimeapps file already exists, as some packages (e.g. firefox) will overwrite it.
    # See https://github.com/nix-community/home-manager/issues/1213.
    configFile."mimeapps.list".force = true;

    mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = "org.gnome.Evince.desktop";
        "x-scheme-handler/magnet" = "transmission-gtk.desktop";
      };
    };
  };
}
