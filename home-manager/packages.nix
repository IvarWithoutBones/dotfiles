{ config
, pkgs
, lib
, ...
}:

{
  home.packages = with pkgs; [
    github-cli
    wget
    curl
    ripgrep
    htop
    unar
    python3
    file
    jq
    killall
    fd
    nix-prefetch-git
    binutils
    act
    element-desktop
    hexyl
    pcalc
    eza
    gimp
    moonlight-qt
    keepassxc
    jellyfin-media-player

    # Packages from my overlay
    dotfiles-tool
    nix-search-fzf
    mkscript
    cat-command
    copy-nix-derivation
    transcode-video
  ] ++ lib.optionals pkgs.stdenvNoCC.hostPlatform.isDarwin [
    iterm2
    read-macos-alias
  ] ++ lib.optionals pkgs.stdenvNoCC.hostPlatform.isLinux [
    noto-fonts-color-emoji
    nerd-fonts.fira-code

    perf
    kdePackages.kcachegrind
    valgrind
    imhex
    ghidra
    mqtt-explorer
    kicad
    vscode-fhs
    zed-editor-fhs
    usbutils
    pciutils
    picoscope

    signal-desktop
    tidal-hifi
    obsidian
    evince
    drawio
    psst
    krita
    _1password-gui
    transmission_4-gtk
    firefox
    libreoffice
    brightnessctl
  ];

  xdg.mimeApps.defaultApplications = lib.mkIf config.xdg.mimeApps.enable {
    "application/pdf" = "org.gnome.Evince.desktop";
    "x-scheme-handler/magnet" = "transmission-gtk.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
  };
}
