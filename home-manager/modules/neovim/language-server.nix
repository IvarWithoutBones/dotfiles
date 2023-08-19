{ lib
, pkgs
, dotfiles-lib
, ...
}:

let
  # A hacky way to add packages to neovims environment if they are not already in $PATH.
  # Needed to allow projects to overwrite tools bundled with neovim, for example using a nightly rust toolchain.
  # This would be much easier if the home-manager module allowed us to define `extraWrapperArgs`, but alas.
  nvimWithDefaultPackages = packages:
    pkgs.runCommand "neovim-wrapped"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      } ''
      # Symlinking is being a bit painful here. The desktop file is attempted to be
      # removed by the home-manager module, which it can't if this derivation does not own it.
      mkdir -p $out
      cp -r ${pkgs.neovim-unwrapped}/* $out
      chmod -R +w $out

      makeWrapper ${pkgs.neovim-unwrapped}/bin/nvim $out/bin/nvim \
        --suffix PATH : ${lib.makeBinPath packages}
    '';
in
{
  programs.nixvim = {
    package = with pkgs; nvimWithDefaultPackages [
      ltex-ls # Spelling suggestions
      taplo-lsp # TOML
      yaml-language-server # YAML
      nodePackages.typescript-language-server # Typescript/Javascript
      nodePackages.vscode-json-languageserver # JSON
      nodePackages.vscode-html-languageserver-bin # HTML
      python3Packages.python-lsp-server # Python
      sumneko-lua-language-server # Lua
      cmake-language-server # CMake

      # C/C++
      clang-tools
      clang

      # C#
      dotnet-sdk_6
      omnisharp-roslyn

      # Bash
      shellcheck
      nodePackages.bash-language-server

      # Nix
      nil-language-server
      nixpkgs-fmt

      # Rust
      cargo
      rustfmt
      rustc
      clippy
      rust-analyzer
    ];

    extraPlugins = with pkgs.vimPlugins; [
      nvim-lspconfig # Language server configuration presets
      coq_nvim # Completion engine

      # Snippets & more
      coq-artifacts
      coq-thirdparty
    ];

    extraConfigVim =
      let
        language-server = pkgs.substituteAll {
          src = ./scripts/language-server.lua;

          # For a list of available options see the documentation:
          # https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
          languageServers = (dotfiles-lib.generators.toLua {
            omnisharp = { }; # C#
            taplo = { }; # TOML
            bashls = { }; # Bash
            tsserver = { }; # Typescript/Javascript
            jsonls = { }; # JSON
            html = { }; # HTML

            # YAML
            yamlls = {
              settings.redhat = {
                telemetry.enabled = false;
              };
            };

            # Rust
            rust_analyzer = {
              settings."rust-analyzer" = {
                checkOnSave.command = "clippy";
                # Dont show diagnostics for inactive cfg directives
                diagnostics.disabled = [ "inactive-code" ];
              };
            };

            # Nix
            nil_ls = {
              settings.nil = {
                formatting.command = [ "nixpkgs-fmt" ];
              };
            };

            # CMake
            cmake = {
              init_options.buildDirectory = "build";
            };

            # C/C++
            clangd = {
              cmd = [
                "clangd"
                "--background-index"
                "--clang-tidy"
                "--all-scopes-completion"
                "--header-insertion=iwyu"
                "--suggest-missing-includes"
                "--completion-style=detailed"
                "--compile-commands-dir=build"
                "--fallback-style=llvm"
              ];

              capabilities.offsetEncoding = "utf-8";
            };

            # Python
            pylsp = {
              settings.pylsp.plugins.pycodestyle.ignore = [
                "E201" # Whitespace after opening bracket
                "E202" # Whitespace before closing bracket
                "E302" # Two newlines after imports
                "E305" # Two newlines after class/function
                "E501" # Line too long
              ];
            };

            # Lua
            lua_ls = {
              settings.Lua = {
                runtime.version = "LuaJIT";
                diagnostics.globals = [ "vim" ];
                telemetry.enable = false;
              };
            };

            # Spelling suggestions
            ltex = {
              completionEnabled = true;
              settings.ltex = {
                dictionary."en-US" = [
                  "NixOS"
                  "nixos"
                  "Nix"
                  "nix"
                  "dotfiles"
                  "nixpkgs"
                  "neovim"
                  "vim"
                ];
              };
            };
          });
        };
      in
      dotfiles-lib.vim.mkLuaFile language-server;
  };
}
