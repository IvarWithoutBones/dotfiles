{ lib
, stdenvNoCC
, fetchurl
, undmg
, makeWrapper
}:

# qtwebengine is unfortunately broken on x86_64-darwin, so i use the prebuild binary in the meantime

stdenvNoCC.mkDerivation rec {
  pname = "qutebrowser";
  version = "2.5.2";

  src = fetchurl {
    url = "https://github.com/qutebrowser/qutebrowser/releases/download/v${version}/qutebrowser-${version}.dmg";
    hash = "sha256-nFLHreNIUQNoazHknSV22j9X9Du6KwYlKJiKXuYGuzk=";
  };

  sourceRoot = "qutebrowser.app";

  nativeBuildInputs = [
    undmg
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,Applications/qutebrowser.app}
    cp -r Contents $out/Applications/qutebrowser.app
    # Symlinks dont work, the app loads bundled executables from the working directory
    makeWrapper $out/Applications/qutebrowser.app/Contents/MacOS/qutebrowser $out/bin/qutebrowser

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/The-Compiler/qutebrowser";
    description = "Keyboard-focused browser with a minimal GUI";
    license = licenses.gpl3Plus;
    platforms = platforms.darwin;
  };
}
