{ stdenv, writeScript, maim, imagemagick, i3lock }:

stdenv.mkDerivation rec {
  pname = "i3lock";
  version = "1.0";

  src = writeScript "lock.sh" ''
    ${maim}/bin/maim /tmp/lockscreen.png
    ${imagemagick}/bin/convert /tmp/lockscreen.png -blur 5x4 /tmp/lockscreen.png
    ${i3lock}/bin/i3lock -e -n -i /tmp/lockscreen.png
  '';

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/i3lock
  '';

  meta.description = "Simple lock script for i3";
}
