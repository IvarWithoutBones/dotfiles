{ pname
, version
, src
, meta
, stdenvNoCC
, autoPatchelfHook
, makeWrapper
, wrapGAppsHook
, dpkg
, glib-networking
, openssl
, webkitgtk
}:

stdenvNoCC.mkDerivation {
  inherit pname version src meta;

  nativeBuildInputs = [
    wrapGAppsHook
    makeWrapper
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
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall
    cp -r usr $out

    # Environment variable fixes a blank window on nvidia:
    # https://github.com/tauri-apps/tauri/issues/4315#issuecomment-1207755694
    wrapProgram $out/bin/cinny \
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
      ''${gappsWrapperArgs[@]}

    runHook postInstall
  '';
}
