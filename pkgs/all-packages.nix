{ nix-index-database
, nil-language-server
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

  cinny-desktop = import ./cinny-desktop {
    inherit
      lib
      stdenvNoCC
      callPackage
      fetchurl;
  };

  copy-nix-derivation = callPackage ./copy-nix-derivation { };

  createScript = callPackage ./createScript { };

  dotfiles-tool = callPackage ./dotfiles-tool { };

  dmenu-configured = callPackage ./dmenu-configured { };

  git-add-fuzzy = callPackage ./git-add-fuzzy { };

  mkscript = callPackage ./mkscript { };

  mpris-statusbar = callPackage ./mpris-statusbar { };

  nil-language-server = nil-language-server.packages.${stdenvNoCC.hostPlatform.system
    or (throw "Unsupported platform ${stdenvNoCC.hostPlatform.system}")}.nil;

  nix-index-database = nix-index-database.legacyPackages.${stdenvNoCC.hostPlatform.system
    or (throw "Unsupported platform ${stdenvNoCC.hostPlatform.system}")}.database;

  nix-search-fzf = callPackage ./nix-search-fzf { };

  nixpkgs-pr = callPackage ./nixpkgs-pr { };

  read-macos-alias = callPackage ./read-macos-alias { };

  speedtest = callPackage ./speedtest {
    inherit (python3Packages) speedtest-cli;
  };

  yabai = callPackage ./yabai {
    inherit (darwin.apple_sdk.frameworks) Cocoa Carbon ScriptingBridge;
    inherit (darwin.apple_sdk_11_0.frameworks) SkyLight;
  };

  yabai-zsh-completions = callPackage ./yabai-zsh-completions { };
}
