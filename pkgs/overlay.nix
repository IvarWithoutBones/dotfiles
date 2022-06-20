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

  # Previous version does not start anymore
  discord = prev.discord.overrideAttrs (attrs: rec {
    version = "0.0.18";
    src = final.fetchurl {
      url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
      sha256 = "sha256-BBc4n6Q3xuBE13JS3gz/6EcwdOWW57NLp2saOlwOgMI=";
    };
  });
}
