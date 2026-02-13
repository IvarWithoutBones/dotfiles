{
  lib,
  pkgs,
  config,
  ...
}:

let
  # All greasemonkey scripts provided by my overlay
  greasemonkeyScripts = pkgs.linkFarmFromDrvs "qutebrowser-greasemonkey-scripts" (
    lib.mapAttrsToList (name: value: value) pkgs.qutebrowser-scripts.greasemonkey
  );

  userscripts = pkgs.qutebrowser-scripts.userscripts;
in
{
  programs.qutebrowser = {
    enable = true;

    settings = {
      downloads.location.directory = "${config.home.homeDirectory}/downloads";
      colors.webpage.preferred_color_scheme = "dark";
      content = {
        pdfjs = true; # Preview PDFs by default, instead of asking to download them
        blocking.method = "both"; # Block ads by using both a host disallowlist and a content-based blocker
        autoplay = false; # Dont start playing video's automatically
      };

      url = {
        start_pages = "https://www.google.com";
        default_page = "https://www.google.com";
      };

      content = {
        # Allow javascript to read/write to the clipboard
        javascript.clipboard = "access";

        # Disable scrolling past the end of the page, which is an issue with gesture navigation
        user_stylesheets = lib.mkIf pkgs.stdenv.isDarwin (
          lib.toList (pkgs.writeText "qutebrowser-user-stylesheet.css" ''
            * {
              overscroll-behavior: none;
            }
          '').outPath
        );
      };
    };

    keyBindings.normal = {
      # Open videos in mpv
      "<Alt-o>" = "hint links spawn --verbose --detach ${pkgs.mpv}/bin/mpv {hint-url}";
      "<Alt-Shift-o>" = "spawn --verbose --detach ${pkgs.mpv}/bin/mpv {url}";

      # Open the tracker for a nixpkgs PR, script from my overlay
      "<Alt-n>" = "spawn --userscript ${userscripts.nixpkgs-tracker}/bin/qute-nixpkgs-tracker {url}";
      "<Alt-Shift-n>" =
        "hint links spawn --userscript ${userscripts.nixpkgs-tracker}/bin/qute-nixpkgs-tracker {hint-url}";

      # Enter fullscreen mode on a website while keeping qutebrowser windowed
      "<Alt-f>" = "spawn --userscript ${userscripts.fake-fullscreen}/bin/qute-fake-fullscreen";
    };

    aliases = {
      "mpv" = "spawn --verbose --detach ${pkgs.mpv}/bin/mpv {url}";
      "nixpkgs-tracker" =
        "spawn --userscript --output-messages ${userscripts.nixpkgs-tracker}/bin/qute-nixpkgs-tracker {url}";
      "fake-fullscreen" =
        "spawn --userscript --output-messages ${userscripts.fake-fullscreen}/bin/qute-fake-fullscreen";
      "docsrs" = "spawn --userscript --output-messages ${userscripts.docsrs}/bin/qute-docsrs";
    };

    searchEngines = {
      DEFAULT = "https://www.google.com/search?q={}";
      gh = "https://github.com/search?q={}";
      nixpkg = "https://search.nixos.org/packages?query={}&channel=unstable";
      nixpkgs-prs = "https://github.com/NixOS/nixpkgs/pulls?q=is%3Aopen+{}";
      nixpkgs-issues = "https://github.com/NixOS/nixpkgs/issues?q=is%3Aopen+{}";
      repology = "https://repology.org/projects/?search={}";
      pip = "https://pypi.org/search/?q={}";
      yt = "https://www.youtube.com/results?search_query={}";
      protondb = "https://www.protondb.com/search?q={}";
      rstd = "https://doc.rust-lang.org/std/index.html?search={}";
      crates = "https://crates.io/search?q={}";
    };

    quickmarks = {
      github = "https://github.com";
      github-notifications = "https://github.com/notifications";
      github-gists = "https://gist.github.com";
      nix-manual = "https://nixos.org/manual/nix/unstable";
      nixpkgs = "https://github.com/NixOS/nixpkgs";
      nixpkgs-tracker = "https://nixpk.gs/pr-tracker.html";
      nixpkgs-manual = "https://nixos.org/manual/nixpkgs/unstable";
      hydra-trunk = "https://hydra.nixos.org/jobset/nixpkgs/trunk";
      nixos-manual = "https://nixos.org/nixos/manual";
      nixos-options = "https://search.nixos.org/options?channel=unstable";
      home-manager = "https://github.com/nix-community/home-manager";
      home-manager-manual = "https://nix-community.github.io/home-manager";
      home-manager-options = "https://rycee.gitlab.io/home-manager/options.html";
      repology = "https://repology.org/projects";
      dotfiles = "https://github.com/ivarWithoutBones/dotfiles";
      ashley-dotfiles = "https://github.com/kira64xyz/ashley-nix";
      cppreference = "https://en.cppreference.com/w/cpp";
      n64brew = "https://n64brew.dev/wiki";
      protonmail = "https://mail.protonmail.com/inbox";
      youtube = "https://www.youtube.com/";
      catan = "https://colonist.io";
    };

    # Apply the theme
    extraConfig =
      let
        dracula-theme = pkgs.fetchurl {
          name = "qutebrowser-dracula-theme.py";
          url = "https://raw.githubusercontent.com/dracula/qutebrowser/ba5bd6589c4bb8ab35aaaaf7111906732f9764ef/draw.py";
          sha256 = "sha256-skZYKoB8KSf8VG+5vqlSkg1q7uNZxIY/AizgtPxYyjQ=";
        };
      in
      ''
        # Import the theme directly from the nix store path to avoid having to use readFile
        import importlib.util
        import sys
        theme_spec = importlib.util.spec_from_file_location("theme", "${dracula-theme}")
        theme = importlib.util.module_from_spec(theme_spec)
        sys.modules["theme"] = theme
        theme_spec.loader.exec_module(theme)
        # Apply the theme using the function defined in the imported file
        theme.blood(c)
      '';
  };

  home.file.".qutebrowser/greasemonkey" = lib.mkIf pkgs.stdenvNoCC.hostPlatform.isDarwin {
    source = greasemonkeyScripts;
  };

  xdg.configFile = lib.mkIf pkgs.stdenvNoCC.hostPlatform.isLinux {
    "qutebrowser/greasemonkey" = {
      source = greasemonkeyScripts;
    };
  };
}
