{ pkgs, config, ... }:

let
  dracula-theme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/dracula/qutebrowser/ba5bd6589c4bb8ab35aaaaf7111906732f9764ef/draw.py";
    sha256 = "sha256-skZYKoB8KSf8VG+5vqlSkg1q7uNZxIY/AizgtPxYyjQ=";
    name = "qutebrowser-dracula-theme.py";
  };
in {
  programs.qutebrowser = {
    enable = true;

    # Apply theme
    extraConfig = (builtins.readFile dracula-theme) + "blood(c)";

    settings = {
      colors.webpage.preferred_color_scheme = "dark";
      downloads.location.directory = "$HOME/downloads";
      content.javascript.can_access_clipboard = true;
    };
  
    searchEngines = {
      DEFAULT = "https://duckduckgo.com/?q={}";
      git = "https://github.com/search?q={}";
      nix = "https://search.nixos.org/packages?query={}&channel=unstable";
      pip = "https://pypi.org/search/?q={}";
      yt = "https://www.youtube.com/results?search_query={}";
      proton = "https://www.protondb.com/search?q={}";
    };
  
    quickmarks = {
      protonmail = "https://mail.protonmail.com/inbox";
      dotfiles = "https://github.com/ivarWithoutBones/dotfiles";
      nur-actions = "https://github.com/IvarWithoutBones/NUR/actions";
      youtube = "https://www.youtube.com/";
      catan = "https://colonist.io";

      github = "https://github.com";
      github-notifications = "https://github.com/notifications";
      nix-manual = "https://nixos.org/manual/nix/unstable";
      nixpkgs = "https://github.com/NixOS/nixpkgs";
      nixpkgs-prs = "https://github.com/NixOS/nixpkgs/pulls";
      nixpkgs-tracker = "https://nixpk.gs/pr-tracker.html";
      nixpkgs-manual = "https://nixos.org/manual/nixpkgs/unstable";
      hydra-trunk = "https://hydra.nixos.org/jobset/nixpkgs/trunk";
      nixos-manual = "https://nixos.org/nixos/manual";
      nixos-options = "https://search.nixos.org/options?channel=unstable";
      home-manager = "https://github.com/nix-community/home-manager";
      home-manager-manual = "https://nix-community.github.io/home-manager";
      home-manager-options = "https://rycee.gitlab.io/home-manager/options.html";
    };
  };
}
