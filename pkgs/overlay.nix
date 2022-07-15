{ nix-index-database, ... }:

final: prev: {
  dotfiles-tool = final.runCommand "dotfiles-tool"
    {
      src = ./dotfiles.sh;
    } ''
    mkdir -p $out/bin
    install -Dm755 $src $out/bin/dotfiles
  '';

  nix-index-database =
    if final.stdenv.isLinux then
      nix-index-database.legacyPackages.x86_64-linux.database
    else if final.stdenv.isDarwin then
      nix-index-database.legacyPackages.x86_64-darwin.database
    else
      throw "Unsupported platform";

  nix-search-fzf = final.runCommand "nix-search-fzf"
    {
      script = final.substituteAll {
        src = ./nix-search-fzf.sh;
        inherit (final) runtimeShell;

        binPath = with final; lib.makeBinPath [
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

  nixpkgs-pr = final.runCommand "nixpkgs-pr"
    {
      src = final.substituteAll {
        src = ./nixpkgs-pr.sh;
        inherit (final) runtimeShell;

        binPath = with final; final.lib.makeBinPath [
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

  cd-file = final.runCommand "cd-file"
    {
      src = ./cd-file.sh;
    } ''
    mkdir -p $out/bin
    install -Dm755 $src $out/bin/cd-file
  '';

  speedtest = final.runCommand "speedtest"
    {
      script = final.substituteAll {
        src = ./speedtest.sh;
        inherit (final) runtimeShell;

        binPath = with final; final.lib.makeBinPath [
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
}
