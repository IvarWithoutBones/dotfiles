final: prev: {
  dotfiles-tool = final.runCommand "dotfiles-tool" {
    src = ./dotfiles.sh;
  } ''
    mkdir -p $out/bin
    install -Dm755 $src $out/bin/dotfiles
  '';

  nixpkgs-pr = final.runCommand "nixpkgs-pr" {
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

  cd-file = final.runCommand "cd-file" {
    src = ./cd-file.sh;
  } ''
    mkdir -p $out/bin
    install -Dm755 $src $out/bin/cd-file
  '';

  speedtest = final.runCommand "speedtest" {
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
