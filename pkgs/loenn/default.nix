{ lib
, stdenvNoCC
, fetchFromGitHub
, makeDesktopItem
, copyDesktopItems
, makeWrapper
, zip
, love
, luajitPackages
, curl
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "loenn";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "CelestialCartographers";
    repo = "Loenn";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-1srNPJ6xaOWQM18RwTzajWPm/xfUTS/qV/NNYGeeHss=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    zip
    makeWrapper
    copyDesktopItems
  ];

  postPatch = ''
    echo v${finalAttrs.version} > src/assets/VERSION
    echo "Lönn - v${finalAttrs.version} (Nix)" > src/assets/TITLE

    substituteInPlace src/updater.lua \
      --replace-fail "function updater.canUpdate()" "function updater.canUpdate() if true then return false end"
  '';

  buildPhase = ''
    runHook preBuild

    pushd src
    zip -9 -r ../Lönn.love .
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib}

    cp Lönn.love $out/lib
    makeWrapper ${lib.getExe love} $out/bin/loenn \
      --add-flags "--fused $out/lib/Lönn.love" \
      --prefix LD_LIBRARY_PATH ':' ${lib.makeLibraryPath [ curl ]} \
      --prefix LUA_CPATH ';;' ${luajitPackages.nfd}/lib/lua/${luajitPackages.lua.luaversion}/nfd.so

    ln -s $out/bin/loenn $out/bin/Lönn
    install -Dm644 src/assets/logo-256.png $out/share/icons/hicolor/256x256/apps/loenn.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "loenn";
      desktopName = "Lönn";
      comment = "A Visual Map Maker and Level Editor for the game Celeste";
      exec = "${finalAttrs.meta.mainProgram} %F";
      type = "Application";
      icon = "loenn";
      categories = [ "Utility" "Development" "Game" "X-LevelEditor" ];
      keywords = [ "Celeste" "Map" "Level" "Editor" "Loenn" ];
    })
  ];

  meta = {
    description = "A Visual Map Maker and Level Editor for the game Celeste";
    homepage = "https://github.com/CelestialCartographers/Loenn";
    license = lib.licenses.mit;
    mainProgram = "Lönn";
  };
})
