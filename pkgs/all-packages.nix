final: prev:
let
  pkgs = final;
in
with pkgs; {
  apotris = prev.apotris.overrideAttrs (oldAttrs:
    let
      _ = lib.assertMsg (oldAttrs.version == "4.1.0") "Is this override still necessary?";
    in
    {
      version = "4.1.1b";

      # Adds support for shaders in $XDG_DATA_HOME. Should be removed when 4.1.1+ is released.
      src = fetchFromGitea {
        domain = "gitea.com";
        owner = "akouzoukos";
        repo = "apotris";
        rev = "225fe63affe8e5b33d038c48acb151b0b342c060";
        hash = "sha256-QxXhHoXXKZ4ql/EHqqmn1vYfM/PYSR49PZ/9R+952xc=";
        fetchSubmodules = true;
      };

      nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ makeWrapper ];

      postInstall = ''
        # Required for the audio/shaders to be found
        wrapProgram $out/bin/Apotris --chdir "$out"
      '';
    });

  cat-command = callPackage ./cat-command { };

  cd-file = callPackage ./cd-file { };

  copy-nix-derivation = callPackage ./copy-nix-derivation { };

  createScript = callPackage ./createScript { };

  discord-with-openasar = callPackage ./discord-with-openasar {
    inherit (nodePackages) asar;
  };

  dotfiles-tool = callPackage ./dotfiles-tool { };

  dmenu-configured = callPackage ./dmenu-configured { };

  git-add-fuzzy = callPackage ./git-add-fuzzy { };

  git-checkout-fuzzy = callPackage ./git-checkout-fuzzy { };

  git-submodule-reset = callPackage ./git-submodule-reset { };

  iterm2-shell-integration = callPackage ./iterm2-shell-integration { };

  livesplit-one = callPackage ./livesplit-one { };

  loenn = callPackage ./loenn { };

  mkscript = callPackage ./mkscript { };

  nix-search-fzf = callPackage ./nix-search-fzf { };

  probe-rs-udev-rules = callPackage ./probe-rs-udev-rules { };

  proton-ge-runner = callPackage ./proton-ge-runner { };

  qutebrowser-scripts = lib.recurseIntoAttrs (callPackage ./qutebrowser/scripts { });

  read-macos-alias = callPackage ./read-macos-alias { };

  transcode-video = callPackage ./transcode-video { };

  wasm-bindgen-cli_0_2_108 = pkgs.callPackage
    ({ buildWasmBindgenCli
     , fetchCrate
     , rustPlatform
     }:
      let
        _ = lib.assertMsg (!hasAttr "wasm-bindgen-cli" prev) "override not needed anymore";
        src = fetchCrate {
          pname = "wasm-bindgen-cli";
          version = "0.2.108";
          hash = "sha256-UsuxILm1G6PkmVw0I/JF12CRltAfCJQFOaT4hFwvR8E=";
        };
      in
      buildWasmBindgenCli {
        inherit src;

        cargoDeps = rustPlatform.fetchCargoVendor {
          inherit src;
          inherit (src) pname version;
          hash = "sha256-iqQiWbsKlLBiJFeqIYiXo3cqxGLSjNM8SOWXGM9u43E=";
        };
      })
    { };

  yabai-zsh-completions = callPackage ./yabai-zsh-completions { };
}
