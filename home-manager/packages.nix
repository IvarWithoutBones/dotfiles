{ pkgs
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
    feh
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

    # Packages from my overlay
    dotfiles-tool
    nix-search-fzf
    mkscript
    cat-command
    copy-nix-derivation
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

  xdg = lib.mkIf pkgs.stdenvNoCC.hostPlatform.isLinux {
    enable = true;

    # Avoid activation failures when the mimeapps file already exists, as some packages (e.g. firefox) will overwrite it.
    # See https://github.com/nix-community/home-manager/issues/1213.
    configFile."mimeapps.list".force = true;

    mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = "org.gnome.Evince.desktop";
        "image/svg+xml" = "feh.desktop";
        "x-scheme-handler/magnet" = "transmission-gtk.desktop";
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
      };
    };
  };
}
