{ lib
, stdenv
, fetchurl
, makeWrapper
, steam-run
}:

let
  proton-ge = stdenv.mkDerivation rec {
    pname = "proton-ge";
    version = "8-13";

    src = fetchurl {
      url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${version}/GE-Proton${version}.tar.gz";
      hash = "sha256-XdIQYbWqBFidrcWaAxbtkWgKC2G5CFSPNamIhkm/nqo=";
    };

    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,share}
      cp -r * $out/share
      makeWrapper ${steam-run}/bin/steam-run $out/bin/proton-ge --add-flags "$out/share/proton"

      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
      changelog = "https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/GE-Proton${version}";
      description = "Compatibility tool for Steam Play based on Wine and additional components";
      license = licenses.unfree; # Valve uses a custom license, which proton-ge inherited.
      platforms = platforms.linux;
    };
  };
in
stdenv.mkDerivation {
  name = "proton-ge-runner";
  src = ./proton-ge-runner.sh;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ proton-ge ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src $out/bin/proton-ge-runner
    wrapProgram $out/bin/proton-ge-runner --set-default PROTON_GE_BINARY "${proton-ge}/bin/proton-ge"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Wrapper that can launch Proton GE for you, without needing Steam";
    license = licenses.asl20;
    inherit (proton-ge.meta) platforms;
  };
}
