{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  makeWrapper,
  pkg-config,
  libsecret,

  runCommand,
  tree-sitter,
  tree-sitter-grammars,
  pkgsCross,
  linkFarm,
}:

let
  wasi32cc = lib.getExe pkgsCross.wasi32.stdenv.cc;
  wasi-sdk = linkFarm "wasi-sdk" { "bin/clang" = wasi32cc; };
  wasm-ld = linkFarm "wasm-ld" {
    "bin/wasm-ld" = lib.getExe' pkgsCross.wasi32.buildPackages.llvmPackages.lld "wasm-ld";
  };

  tree-sitter-wasm =
    runCommand "tree-sitter-wasm"
      {
        nativeBuildInputs = [
          tree-sitter
          pkgsCross.wasi32.stdenv.cc.bintools
          wasm-ld
        ];

        env.TREE_SITTER_WASI_SDK_PATH = wasi-sdk;
      }
      ''
        mkdir -p $out
        export HOME=$TMPDIR
        tree-sitter build --wasm ${tree-sitter-grammars.tree-sitter-bitbake.src} --output $out/tree-sitter-bitbake.wasm
        tree-sitter build --wasm ${tree-sitter-grammars.tree-sitter-bash.src} --output $out/tree-sitter-bash.wasm
      '';
in
buildNpmPackage (finalAttrs: {
  pname = "language-server-bitbake";
  version = "2.10.0+26b6572";

  src = fetchFromGitHub {
    owner = "yoctoproject";
    repo = "vscode-bitbake";
    rev = "26b657299edb7dfa3aac31890e619148f93ebea4";
    hash = "sha256-4Bgct5kRfb7eDt6s997mTvMInxg3T8PwIelMZZShfnw=";
  };

  # For /package.lock.json
  npmDepsHash = "sha256-RuARheQ2Df7dJKo939/kOE655I19BPmvrDckxr2AIOc=";

  # For /server/package-lock.json
  serverDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-root-deps";
    src = "${finalAttrs.src}/server";
    hash = "sha256-c/YpfMd961+pID7Lt2fx0+1OiWwSUw3etG8+ZwUP3fo=";
  };

  # For /client/package-lock.json
  clientDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-client-deps";
    src = "${finalAttrs.src}/client";
    hash = "sha256-Fi3/UlL8DRL02YBalgr5OwBRYymliOmv8hK0ILIY5iU=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    libsecret
  ];

  npmBuildScript = "compile";
  makeCacheWritable = true;

  postPatch = ''
    # # Do not compile the server in postinstall
    substituteInPlace package.json --replace-fail 'cd server && npm install && cd ../client && npm install && cd ..' ""

    # Do not compile the VSCode extension in the server's prepack
    substituteInPlace server/package.json --replace-fail 'cd .. && npm run compile' ""
  '';

  preBuild = ''
    echo "installing server dependencies"
    pushd server
    npm ci --ignore-scripts $npmInstallFlags "''${npmInstallFlagsArray[@]}" $npmFlags "''${npmFlagsArray[@]}" --cache ${finalAttrs.serverDeps}
    patchShebangs node_modules
    popd

    echo "installing client dependencies"
    pushd client
    npm ci --ignore-scripts $npmInstallFlags "''${npmInstallFlagsArray[@]}" $npmFlags "''${npmFlagsArray[@]}" --cache ${finalAttrs.clientDeps}
    patchShebangs node_modules
    popd
  '';

  preInstall = ''
    # We want to install the (language) server binary
    pushd server
  '';

  preFixup = ''
    # Install files from the client, used as a library by the server
    popd
    cp -r client/ $out/lib/node_modules/

    # Install the tree-sitter wasm binaries
    for bin in ${tree-sitter-wasm}/*; do
      cp $bin $out/lib/node_modules/language-server-bitbake/
    done
  '';

  meta = {
    description = "Bitbake language server";
    homepage = "https://github.com/yoctoproject/vscode-bitbake";
    changelog = "https://github.com/yoctoproject/vscode-bitbake/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
  };
})
