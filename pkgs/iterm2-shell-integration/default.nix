{ lib
, fetchFromGitHub
, stdenvNoCC
}:

stdenvNoCC.mkDerivation {
  pname = "iterm2-shell-integration";
  version = "0.pre+date=2022-09-25";

  src = fetchFromGitHub {
    owner = "gnachman";
    repo = "iterm2-shell-integration";
    rev = "90c7e175d745062701b5308dff996d65a025b6d9";
    sha256 = "sha256-L7e3yNlrzk/sImu8wHl3Sc5TQg/kVQlY2/VBBUUuYww=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/{bash,zsh,fish}
    pushd shell_integration
    cp bash $out/share/bash/iterm2.bash
    cp zsh $out/share/zsh/iterm2.zsh
    cp fish $out/share/fish/iterm2.fish
    popd

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/gnachman/iTerm2-shell-integration";
    description = "Shell integration and utilities for iTerm2";
    license = with licenses; [ gpl2Only /* or */ gpl2Plus ];
  };
}
