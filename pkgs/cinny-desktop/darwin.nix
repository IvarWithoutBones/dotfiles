{ pname
, version
, src
, meta

, stdenvNoCC
, undmg
}:

stdenvNoCC.mkDerivation {
  inherit pname version src meta;

  nativeBuildInputs = [
    undmg
  ];

  unpackPhase = ''
    runHook preUnpack
    undmg $src
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,Applications}
    cp -r ./Cinny.app $out/Applications
    ln -s $out/Applications/Cinny.app/Contents/MacOS/Cinny $out/bin

    runHook postInstall
  '';
}
