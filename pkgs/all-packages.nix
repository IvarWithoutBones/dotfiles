{ nix-index-database, ... }:

final: prev:
let
  pkgs = final;
in
with pkgs; {
  cat-command = callPackage ./cat-command { };

  cd-file = callPackage ./cd-file { };

  createScript = callPackage ./createScript { };

  dotfiles-tool = callPackage ./dotfiles-tool { };

  dmenu-configured = callPackage ./dmenu-configured { };

  mkscript = callPackage ./mkscript { };

  nix-index-database =
    if stdenv.isLinux then
      nix-index-database.legacyPackages.x86_64-linux.database
    else if stdenv.isDarwin then
      nix-index-database.legacyPackages.x86_64-darwin.database
    else
      throw "Unsupported platform";

  nix-search-fzf = callPackage ./nix-search-fzf { };

  nixpkgs-pr = callPackage ./nixpkgs-pr { };

  speedtest = callPackage ./speedtest {
    inherit (python3Packages) speedtest-cli;
  };

  yabai = callPackage ./yabai {
    inherit (darwin.apple_sdk.frameworks) Cocoa Carbon ScriptingBridge;
    inherit (darwin.apple_sdk_11_0.frameworks) SkyLight;
  };
}
