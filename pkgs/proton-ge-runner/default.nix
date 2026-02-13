{
  lib,
  stdenv,
  makeWrapper,
  proton-ge-bin,
  steam-run,
}:

stdenv.mkDerivation {
  name = "proton-ge-runner";

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper ${lib.getExe steam-run} $out/bin/proton-ge-runner \
      --add-flag "${./proton-ge-runner.sh}" \
      --set-default PROTON_GE_BINARY "${lib.getOutput "steamcompattool" proton-ge-bin}/proton"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Wrapper that can launch Proton GE for you, without needing Steam";
    license = licenses.asl20;
    inherit (proton-ge-bin.meta) platforms;
  };
}
