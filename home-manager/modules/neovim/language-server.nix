{ lib
, config
, pkgs
, dotfiles-lib
, ...
}:

{
  programs.neovim = {
    extraPackages = with pkgs; [
      shellcheck # Bash

      # C/C++
      clang-tools
      clang

      # Rust
      cargo
      rustfmt
      rustc
    ];

    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig # Language server presets
      coq_nvim # Completion engine
      trouble-nvim # Interactive diagnostics in bottom bar
      nvim-code-action-menu # Interactive code actions

      # Snippets & more
      coq-artifacts
      coq-thirdparty
    ];

    extraConfig =
      let
        language-server = pkgs.substituteAll {
          src = ./scripts/language-server.lua;

          # For a list of available options see the documentation:
          # https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
          languageServers = (dotfiles-lib.generators.toLua {
            bashls.cmd = [ "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server" "start" ];
            rust_analyzer.cmd = [ "${pkgs.rust-analyzer}/bin/rust-analyzer" ];
            rnix.cmd = [ "${pkgs.rnix-lsp}/bin/rnix-lsp" ];

            omnisharp = {
              cmd = [ "${pkgs.omnisharp-roslyn}/bin/OmniSharp" ];
              enable_roslyn_analyzers = true;
              enable_import_completion = true;
            };

            # Currently broken on darwin due to poetry failing
            cmake = lib.optionalAttrs (!pkgs.stdenvNoCC.hostPlatform.isDarwin) {
              cmd = [ "${pkgs.cmake-language-server}/bin/cmake-language-server" ];
              init_options.buildDirectory = "build";
            };

            clangd = {
              cmd = [
                "${pkgs.clang-tools_14}/bin/clangd"
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

            pylsp = {
              cmd = [ "${pkgs.python3Packages.python-lsp-server}/bin/pylsp" ];
              settings.pylsp.plugins.pycodestyle.ignore = [
                "E201" # Whitespace after opening bracket
                "E202" # Whitespace before closing bracket
                "E302" # Two newlines after imports
                "E305" # Two newlines after class/function
                "E501" # Line too long
              ];
            };

            sumneko_lua = {
              cmd = [ "${pkgs.sumneko-lua-language-server}/bin/lua-language-server" ];
              settings.Lua = {
                runtime.version = "LuaJIT";
                diagnostics.globals = [ "vim" ];
                telemetry.enable = false;
              };
            };

            # Spelling suggestions for markdown/git commit messages
            ltex = {
              cmd = [ "${pkgs.ltex-ls}/bin/ltex-ls" ];
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
