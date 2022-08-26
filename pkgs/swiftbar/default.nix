{ lib
, fetchzip
, stdenvNoCC
, makeWrapper
}:

stdenvNoCC.mkDerivation rec {
  pname = "swiftbar";
  version = "1.4.3";

  src = fetchzip {
    url = "https://github.com/swiftbar/SwiftBar/releases/download/v${version}/SwiftBar.zip";
    sha256 = "sha256-Ut+lr1E7bMp8Uz1aL7EV0ZsfdTh9t7zUjDU/DScRpHY=";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r ./SwiftBar.app/* $out
    # Symlink doesnt work for some reason
    makeWrapper $out/Contents/MacOS/SwiftBar $out/bin/SwiftBar

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://swiftbar.app";
    description = "Powerful macOS menu bar customization tool";
    mainProgram = "SwiftBar";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
