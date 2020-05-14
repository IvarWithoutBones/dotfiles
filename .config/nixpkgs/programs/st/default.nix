{ stdenv, fetchFromGitHub, pkgconfig, writeText, libX11, ncurses
, libXft, conf ? null, patches ? [], extraLibs ? []}:

stdenv.mkDerivation rec {
  pname = "st";
  version = "unstable-2020-05-13";

  src = fetchFromGitHub {
    owner = "LukeSmithxyz";
    repo = "st";
    rev = "74b68b32fab4d039b43cf5631c0617fcde1e9bbf";
    sha256 = "1gnbldsznir21f6smlfphxk3396q6rwzaf02zahfzqad7nw0rj99";
  };

  inherit patches;

  configFile = stdenv.lib.optionalString (conf!=null) (writeText "config.def.h" conf);
  postPatch = stdenv.lib.optionalString (conf!=null) "cp ${configFile} config.def.h";

  nativeBuildInputs = [ pkgconfig ncurses ];
  buildInputs = [ libX11 libXft ] ++ extraLibs;

  installPhase = ''
    TERMINFO=$out/share/terminfo make install PREFIX=$out
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/lukesmithxyz/st";
    description = "Simple Terminal fork from Luke Smith";
    license = licenses.mit;
    maintainers = with maintainers; [ ivar ];
    platforms = platforms.linux;
  };
}
