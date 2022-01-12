{ pkgs, config, ... }:

let
  dracula-theme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/dracula/qutebrowser/ba5bd6589c4bb8ab35aaaaf7111906732f9764ef/draw.py";
    sha256 = "sha256-skZYKoB8KSf8VG+5vqlSkg1q7uNZxIY/AizgtPxYyjQ=";
  };
in {
  programs.qutebrowser = {
    enable = true;

    # Apply theme
    extraConfig = (builtins.readFile dracula-theme) + "blood(c)";

    settings.downloads.location.directory = "$HOME/downloads";
  
    searchEngines = {
      DEFAULT = "https://duckduckgo.com/?q={}";
      git = "https://github.com/search?q={}";
      nix = "https://search.nixos.org/packages?query={}&sort=relevance&channel=unstable";
      pip = "https://pypi.org/search/?q={}";
      yt = "https://www.youtube.com/results?search_query={}";
      proton = "https://www.protondb.com/search?q={}";
    };
  
    quickmarks = {
      nixpkgs = "https://github.com/NixOS/nixpkgs";
      nixpkgs-manual = "https://nixos.org/manual/nixpkgs/unstable/";
      nixos-options = "https://search.nixos.org/options?channel=unstable";
      nixos-manual = "https://nixos.org/nixos/manual/";
      home-manager = "https://github.com/nix-community/home-manager";
      home-manager-options = "https://rycee.gitlab.io/home-manager/options.html";
      home-manager-manual = "https://nix-community.github.io/home-manager/";

      github = "https://github.com/";
      dotfiles = "https://github.com/ivarWithoutBones/dotfiles";
      nur-actions = "https://github.com/IvarWithoutBones/NUR/actions";

      youtube = "https://www.youtube.com/";
      protonmail = "https://mail.protonmail.com/inbox";
      catan = "https://colonist.io";
    };
  };
}
