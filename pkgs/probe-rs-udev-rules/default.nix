{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "probe-rs-udev-rules";
  version = "0.pre+date=2025-12-02";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/probe-rs/webpage/756e0bfdf0366190ae64ae0a1c22a8052418d1dd/public/files/69-probe-rs.rules";
    hash = "sha256-yjxld5ebm2jpfyzkw+vngBfHu5Nfh2ioLUKQQDY4KYo=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/udev/rules.d
    cp $src $out/lib/udev/rules.d/69-probe-rs.rules

    runHook postInstall
  '';

  meta = {
    description = "udev rules for embedded debug probes supported by probe-rs";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
