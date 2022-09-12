{ pname
, version
, src
, meta

, stdenv
, autoPatchelfHook
, wrapGAppsHook
, dpkg
, glib-networking
, openssl
, webkitgtk
}:

stdenv.mkDerivation {
  inherit pname version src meta;

  nativeBuildInputs = [
    wrapGAppsHook
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    glib-networking
    openssl
    webkitgtk
  ];

  unpackCmd = "dpkg-deb -x $src source";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    cp -r usr $out
    runHook postInstall
  '';
}
