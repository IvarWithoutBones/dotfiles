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
    binutils
    act
    element-desktop
    hexyl
    pcalc
    cargo-flamegraph
    eza
    gimp
    moonlight-qt
    keepassxc

    # Packages from my overlay
    dotfiles-tool
    nixpkgs-pr
    nix-search-fzf
    mkscript
    cat-command
    callpackage-cli
    copy-nix-derivation
    read-macos-alias
  ] ++ lib.optionals pkgs.hostPlatform.isDarwin [
    iterm2
  ] ++ lib.optionals pkgs.hostPlatform.isLinux [
    # Package from my overlay
    speedtest
    proton-ge-runner

    noto-fonts-emoji
    nerd-fonts.fira-code

    perf
    kdePackages.kcachegrind
    valgrind
    prismlauncher
    signal-desktop
    tidal-hifi
    obsidian
    ghidra
    vscode-fhs
    ares
    evince
    drawio
    imhex
    psst
    krita
    _1password-gui
    transmission_4-gtk
    firefox
    libreoffice
  ];

  # TODO: Move to a separate XDG file.
  xdg = lib.mkIf pkgs.hostPlatform.isLinux {
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
      };
    };
  };
}
