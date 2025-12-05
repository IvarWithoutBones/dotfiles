{ lib
, stdenvNoCC
, replaceVars
, fetchFromGitHub
, makeDesktopItem
, copyDesktopItems
, makeWrapper
, zip
, love
, luajitPackages
, curl

  # Override with `true` to make Lönn use the Celeste game directory managed by Nix
, withCeleste ? false
, celestegame
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

  patches = [
    ./disable-auto-update.patch
  ] ++ lib.optionals withCeleste [
    (replaceVars ./game-directory.patch {
      celeste = celestegame.passthru.celeste-unwrapped;
    })
  ];

  nativeBuildInputs = [
    zip
    makeWrapper
    copyDesktopItems
  ];

  postPatch = ''
    echo v${finalAttrs.version} > src/assets/VERSION
    echo "Lönn - v${finalAttrs.version} (nixpkgs)" > src/assets/TITLE
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
      --prefix LUA_CPATH ';' ${luajitPackages.nfd}/lib/lua/${luajitPackages.lua.luaversion}/nfd.so

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
    changelog = "https://github.com/CelestialCartographers/Loenn/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    mainProgram = "Lönn";
  };
})
