{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchNpmDeps,
  fetchpatch,
  wrapGAppsHook4,
  replaceVars,
  cargo-tauri,
  glib-networking,
  nodejs,
  npmHooks,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  lld,
  wasm-bindgen-cli_0_2_108,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "LiveSplitOne";
  version = "2026-04-14";

  src = fetchFromGitHub {
    owner = "LiveSplit";
    repo = "LiveSplitOne";
    rev = "83ae5560d80bbf849697c9fb6d5482b6944da530";
    sha256 = "sha256-Sx90cd8CKK+Der5O74uarV+uti67zSAdFF95np6GzMc=";
    fetchSubmodules = true;
  };

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-R1GmLyaGlD4948goV7EiFkPb6PJcILr1NpC4lVGWNZA=";
  };

  cargoLock.lockFile = ./LiveSplitOne-Cargo.lock; # The lockfile for the Tauri app, the upstream lockfile is outdated

  livesplitCoreCargoDeps = rustPlatform.importCargoLock {
    lockFile = ./livesplit-core-Cargo.lock; # The lockfile from the livesplit-core submodule
  };

  patches = [
    (replaceVars ./static-build-info.patch {
      shortRev = lib.substring 0 7 finalAttrs.src.rev;
      date = finalAttrs.version;
    })
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    (fetchpatch {
      # Fixes popout windows on Linux: https://github.com/LiveSplit/LiveSplitOne/pull/1137
      url = "https://github.com/DaVinciLord/LiveSplitOne/commit/e71bec425944f2947b47350aa1349b8f27bf2685.patch";
      hash = "sha256-ylbRi+ac0ZE+nw3jxT4GEQG0uq5meCHw9OKJjh3zes8=";
    })
  ];

  nativeBuildInputs = [
    cargo-tauri.hook
    wasm-bindgen-cli_0_2_108
    pkg-config
    lld
    npmHooks.npmConfigHook
    nodejs
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
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

  postPatch = ''
    ln -sf ${./LiveSplitOne-Cargo.lock} src-tauri/Cargo.lock
  '';

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
