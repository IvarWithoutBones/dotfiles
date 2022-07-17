{ nix-index-database, ... }:

final: prev: let
  pkgs = final;
in {
  dotfiles-tool = pkgs.runCommand "dotfiles-tool"
    {
      src = ./dotfiles.sh;
    } ''
    mkdir -p $out/bin
    install -Dm755 $src $out/bin/dotfiles
  '';

  nix-index-database =
    if pkgs.stdenv.isLinux then
      nix-index-database.legacyPackages.x86_64-linux.database
    else if pkgs.stdenv.isDarwin then
      nix-index-database.legacyPackages.x86_64-darwin.database
    else
      throw "Unsupported platform";

  nix-search-fzf = pkgs.runCommand "nix-search-fzf"
    {
      script = pkgs.substituteAll {
        src = ./nix-search-fzf.sh;
        inherit (pkgs) runtimeShell;

        binPath = with pkgs; lib.makeBinPath [
          gnused
          jq
          fzf
          nix
          coreutils
          bash
        ];
      };
    } ''
    mkdir -p $out/bin
    install -Dm755 $script $out/bin/nix-search-fzf
  '';

  nixpkgs-pr = pkgs.runCommand "nixpkgs-pr"
    {
      src = pkgs.substituteAll {
        src = ./nixpkgs-pr.sh;
        inherit (pkgs) runtimeShell;

        binPath = with pkgs; lib.makeBinPath [
          nix
          curl
          git
          pandoc
          gnused
          pandoc
          jq
          coreutils
          python3
          curl
          xdg_utils
        ];
      };
    } ''
    mkdir -p $out/bin
    install -Dm755 $src $out/bin/nixpkgs-pr
  '';

  cd-file = pkgs.runCommand "cd-file"
    {
      src = ./cd-file.sh;
    } ''
    mkdir -p $out/bin
    install -Dm755 $src $out/bin/cd-file
  '';

  speedtest = pkgs.runCommand "speedtest"
    {
      script = pkgs.substituteAll {
        src = ./speedtest.sh;
        inherit (pkgs) runtimeShell;

        binPath = with pkgs; lib.makeBinPath [
          python3Packages.speedtest-cli
          iputils
          coreutils
          gnugrep
        ];
      };
    } ''
    mkdir -p $out/bin
    install -Dm755 $script $out/bin/speedtest
  '';

  dmenu = pkgs.runCommand "dmenu-configured"
    {
      dmenu = prev.dmenu;
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
    mkdir -p $out/bin
    for bin in $dmenu/bin/*; do
      # TODO: dont hardcode the colors and font
      makeWrapper $bin $out/bin/$(basename ''${bin}) \
        --add-flags "-nf '#cdd6f4' -nb '#12121c' -sb '#cba6f7' -sf '#12121c' -fn 'FiraCode-13'"
    done
  '';
}
