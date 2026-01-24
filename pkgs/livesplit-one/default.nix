{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, fetchNpmDeps
, wrapGAppsHook4
, replaceVars
, cargo-tauri
, glib-networking
, nodejs
, npmHooks
, openssl
, pkg-config
, webkitgtk_4_1
, lld
, wasm-bindgen-cli_0_2_108
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "LiveSplitOne";
  version = "2026-01-12";

  src = fetchFromGitHub {
    owner = "LiveSplit";
    repo = "LiveSplitOne";
    rev = "ca1b6dffa553c8c6b986418e69d0df8d5847e5f3";
    sha256 = "sha256-M22N4RCXcnQwkc+KAz04C3mp8TK0De8UVmqkmH8V9EY=";
    fetchSubmodules = true;
  };

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-nYujVmInG+4n0FafYs4lyd9hquo29/rVmaAKGyjJF40=";
  };

  cargoHash = "sha256-FE1pveaKdYYkq0COV1i97rf5P26G85I9H3bnMYDo7m8=";

  livesplitCoreCargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock; # The lockfile from the livesplit-core submodule
  };

  patches = [
    (replaceVars ./static-build-info.patch {
      inherit (finalAttrs.src) rev;
      date = finalAttrs.version;
    })
  ];

  nativeBuildInputs = [
    cargo-tauri.hook
    wasm-bindgen-cli_0_2_108
    pkg-config
    lld
    npmHooks.npmConfigHook
    nodejs
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook4
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    openssl
    webkitgtk_4_1
  ];

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  doCheck = false;

  preBuild = ''
    # Switch to the livesplit-core Cargo deps, build it, then switch back for Tauri
    substituteInPlace $NIX_BUILD_TOP/.cargo/config.toml --replace-fail "directory =" "directory = \"$livesplitCoreCargoDeps\" #"
    npm run build:core:release
    substituteInPlace $NIX_BUILD_TOP/.cargo/config.toml --replace-fail "directory =" "directory = \"$cargoDeps\" #"

    # Generate the icons and HTML for Tauri
    npm run tauri:icons
    npm run tauri:build-html
  '';

  dontWrapGApps = stdenv.hostPlatform.isLinux;

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    ln -s $out/bin/"LiveSplit One" $out/bin/livesplit-one

    # Spaces in the icon path seem to break gtk-update-icon-cache
    for dir in $out/share/icons/hicolor/*; do
      mv "$dir/apps/LiveSplit One.png" "$dir/apps/livesplit-one.png"
    done

    substituteInPlace $out/share/applications/"LiveSplit One.desktop" \
      --replace-fail "Icon=LiveSplit One" "Icon=livesplit-one" \
      --replace-fail "Comment=A Tauri App" "Comment=${finalAttrs.meta.description}"
  '';

  meta = {
    description = "Timer program for speedrunners";
    homepage = "https://github.com/LiveSplit/LiveSplitOne";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
