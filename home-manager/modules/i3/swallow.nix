{ lib
, buildPythonApplication
, fetchPypi
, i3ipc
, xlib
, six
}:

buildPythonApplication rec {
  pname = "i3-swallow";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-ROHHp6yx7rjkA6G2+jULW6Vv5gh4CXy1WHPM/PVpdrg=";
  };

  propagatedBuildInputs = [
    i3ipc
    xlib
    six
  ];

  # No tests available
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/ViliamV/i3-swallow";
    description = "Swallow a terminal window in i3wm";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "swallow";
    maintainers = [ maintainers.ivar ];
  };
}
