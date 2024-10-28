{ nix-index-database
, nil-language-server
, sm64ex-practice
, helix
, ...
}:

final: prev:
let
  pkgs = final;
in
with pkgs; {
  callpackage-cli = callPackage ./callpackage-cli { };

  cat-command = callPackage ./cat-command { };

  cd-file = callPackage ./cd-file { };

  copy-nix-derivation = callPackage ./copy-nix-derivation { };

  createScript = callPackage ./createScript { };

  discord-with-openasar = callPackage ./discord-with-openasar {
    inherit (nodePackages) asar;
  };

  dotfiles-tool = callPackage ./dotfiles-tool { };

  dmenu-configured = callPackage ./dmenu-configured { };

  git-add-fuzzy = callPackage ./git-add-fuzzy { };

  helix-git = helix.packages.${hostPlatform.system or (throw "Unsupported platform ${hostPlatform.system}")}.helix;

  iterm2-shell-integration = callPackage ./iterm2-shell-integration { };

  mkscript = callPackage ./mkscript { };

  nil-language-server = nil-language-server.packages.${hostPlatform.system or (throw "Unsupported platform ${hostPlatform.system}")}.nil;

  nix-index-database = nix-index-database.legacyPackages.${hostPlatform.system or (throw "Unsupported platform ${hostPlatform.system}")}.database;

  nix-search-fzf = callPackage ./nix-search-fzf { };

  nixpkgs-pr = callPackage ./nixpkgs-pr { };

  proton-ge-runner = callPackage ./proton-ge-runner { };

  qutebrowser-scripts = lib.recurseIntoAttrs (callPackage ./qutebrowser/scripts { });

  # The qt6 version of qtwebengine (which qutebrowser by default depends on) is not in the binary cache on Darwin,
  # presumably because of a build failure. We can simply use the qt5 version instead for now.
  qutebrowser =
    if stdenvNoCC.isDarwin then prev.qutebrowser-qt5
    else prev.qutebrowser;

  read-macos-alias = callPackage ./read-macos-alias { };

  sm64ex-practice = sm64ex-practice.packages.${stdenvNoCC.hostPlatform.system
    or (throw "Unsupported platform ${stdenvNoCC.hostPlatform.system}")}.default;

  speedtest = callPackage ./speedtest {
    inherit (python3Packages) speedtest-cli;
  };

  tree-sitter-grammars = prev.tree-sitter-grammars //
    lib.recurseIntoAttrs (import ./tree-sitter-grammars);

  yabai-zsh-completions = callPackage ./yabai-zsh-completions { };
}
