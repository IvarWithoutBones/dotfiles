{ lib
, stdenv
, writeShellScript
, hostPlatform
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

let
  loadScriptingAddition = writeShellScript "yabai-load-sa" ''

    # For whatever reason the regular commands to load the scripting addition do not work, yabai will throw an error.
    # The installation command mutably installs binaries to '/System', but then fails to start them. Manually running
    # the bins as root does start the scripting addition, so this serves as a more user-friendly way to do that.

    set -euo pipefail

    if [[ "$EUID" != 0 ]]; then
        echo "error: the scripting-addition loader must ran as root. try 'sudo $0'"
        exit 1
    fi

    loaderPath="/Library/ScriptingAdditions/yabai.osax/Contents/MacOS/mach_loader";

    if ! test -f "$loaderPath" || ! test -f "$loaderPath"; then
        echo "could not locate the scripting-addition loader at '$loaderPath', installing it..."
        echo "note: this may display an error"

        eval "$(dirname "''${BASH_SOURCE[0]}")/yabai --install-sa" || true
        sleep 1
    fi

    echo "executing loader..."
    eval "$loaderPath"
    echo "scripting-addition started"
  '';
in
stdenv.mkDerivation rec {
  pname = "yabai";
  version = "4.0.2";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = "yabai";
    rev = "v${version}";
    sha256 = "sha256-DXDdjI4kkLcRUNtMoSu7fJ0f3fUty88o5ZS6lJz0cGU=";
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
    # aarch64 code is compiled on all targets, which causes Apple SDK headers to error out.
    # Since multilib doesnt work on darwin i dont know of a better way of handling this.
    substituteInPlace makefile \
      --replace "-arch arm64e" "" \
      --replace "-arch arm64" ""

    # `NSScreen::safeAreaInsets` is only available on macOS 12.0 and above, which frameworks arent packaged.
    # When a lower OS version is detected upstream just returns 0, so we can hardcode that at compiletime.
    # https://github.com/koekeishiya/yabai/blob/v4.0.2/src/workspace.m#L109
    substituteInPlace src/workspace.m \
      --replace 'return screen.safeAreaInsets.top;' 'return 0;'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/{man/man1,icons/hicolor/scalable/apps}}

    cp ./bin/yabai $out/bin/yabai
    ln -s ${loadScriptingAddition} $out/bin/yabai-load-sa
    cp ./doc/yabai.1 $out/share/man/man1/yabai.1
    cp ./assets/icon/icon.svg $out/share/icons/hicolor/scalable/apps/yabai.svg

    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion {
    package = yabai;
    version = "yabai-v${version}";
  };

  meta = with lib; {
    description = "A tiling window manager for macOS based on binary space partitioning";
    longDescription = ''
      yabai is a window management utility that is designed to work as an extension to the built-in
      window manager of macOS. yabai allows you to control your windows, spaces and displays freely
      using an intuitive command line interface and optionally set user-defined keyboard shortcuts
      using skhd and other third-party software.

      Note that due to a nix-only bug the scripting addition cannot be launched using the regular
      procedure. Instead, you can use the provided `yabai-load-sa` script.
    '';
    homepage = "https://github.com/koekeishiya/yabai";
    changelog = "https://github.com/koekeishiya/yabai/blob/v${version}/CHANGELOG.md";
    license = licenses.mit;
    platforms = platforms.darwin;
    # Fails to find `<Foundation/Foundation.h>` when cross compiling from x86_64-darwin, even with `CoreFoundation` added in `buildInputs`.
    broken = hostPlatform.isAarch64;
    maintainers = with maintainers; [
      cmacrae
      shardy
      ivar
    ];
  };
}
