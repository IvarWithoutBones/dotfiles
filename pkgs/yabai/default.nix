{ lib
, stdenv
, fetchFromGitHub
, testers
, yabai
, xxd
, xcodebuild
, Carbon
, Cocoa
, ScriptingBridge
  # This needs to be from SDK 10.13 or higher, SLS APIs introduced in that version get used
, SkyLight
}:

stdenv.mkDerivation rec {
  pname = "yabai";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = "yabai";
    rev = "v${version}";
    sha256 = "sha256-H1zMg+/VYaijuSDUpO6RAs/KLAAZNxhkfIC6CHk/xoI=";
  };

  nativeBuildInputs = [
    xcodebuild
    xxd
  ];

  buildInputs = [
    Carbon
    Cocoa
    ScriptingBridge
    SkyLight
  ];

  dontConfigure = true;
  enableParallelBuilding = true;

  postPatch = ''
    # aarch64 code is compiled on all targets, which causes Apple SDK headers to error out. The scripting addition
    # might depend on arm64e, but since multilib doesnt work on darwin i dont know of a better way of handling this.
    substituteInPlace makefile \
      --replace "-arch arm64e" "" \
      --replace "-arch arm64" ""

    # `NSScreen::safeAreaInsets` is only available on macOS 12.0 and above, which frameworks arent packaged.
    # When on lower OS versions or other conditions fail, upstream just returns 0, so we can do the same.
    # https://github.com/koekeishiya/yabai/blob/v4.0.1/src/workspace.m#L109 
    substituteInPlace src/workspace.m \
      --replace 'return screen.safeAreaInsets.top;' 'return 0;'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/man/man1/
    cp ./bin/yabai $out/bin/yabai
    cp ./doc/yabai.1 $out/share/man/man1/yabai.1

    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion {
    package = yabai;
    version = "yabai-v${version}";
  };

  meta = with lib; {
    description = "A tiling window manager for macOS based on binary space partitioning";
    homepage = "https://github.com/koekeishiya/yabai";
    changelog = "https://github.com/koekeishiya/yabai/blob/v${version}/CHANGELOG.md";
    platforms = platforms.darwin;
    license = licenses.mit;
    maintainers = with maintainers; [
      cmacrae
      shardy
      ivar
    ];
  };
}
