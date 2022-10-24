{ lib
, config
, pkgs
, ...
}:

let
  mkLua = lua: ''
    lua << EOF
      ${lua}
    EOF
  '';
in
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
      trouble-nvim # Diagnostics in bottom bar

      # Snippets & more
      coq-artifacts
      coq-thirdparty
    ];

    # TODO: convert to lua file
    extraConfig = mkLua ''
      -- Always show the signcolumn, otherwise text would be shifted upon errors
      vim.opt.signcolumn = "yes"

      local signs = {
        Error = "",
        Warn = "",
        Hint = "",
        Info = ""
      }

      -- Replace existing signs for diagnostics with our icons
      for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
      end

      -- Rounded corners for popup boxes
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
        vim.lsp.handlers.hover, {border = 'rounded'}
      )
      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {border = 'rounded'}
      )

      -- Use tab indentation size from the language server
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function()
          vim.opt.tabstop = vim.lsp.util.get_effective_tabstop()
        end
      })

      -- Interactive diagnostic settings
      require("trouble").setup {
        auto_close = true,
        use_diagnostic_signs = true,
      }

      -- Completion settings
      vim.g.coq_settings = {
        auto_start = 'shut-up',               -- Load the completion engine on startup
        xdg = true,                           -- Dont try to install dependencies to the nix store
        ["clients.lsp.always_on_top"] = { },  -- Always show LSP completions above other sources
        ["display.pum.fast_close"] = false,   -- Stops some flickering
        ["keymap.manual_complete"] = '<C-c>', -- Manually trigger completion
      }

      -- Mappings. See `:help vim.lsp.*` for documentation on the below functions
      local options = function(client, bufnr)
        local bufopts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', '<space>A', "<cmd>TroubleToggle workspace_diagnostics<cr>", bufopts)                           -- Open all diagnostics
        vim.keymap.set('n', '<space>a', "<cmd>TroubleToggle document_diagnostics<cr>", bufopts)                            -- Open document diagnostics
        vim.keymap.set('n', 'gD', "<cmd>TroubleToggle lsp_type_definitions<cr>", bufopts)                                  -- Jump to type definitions
        vim.keymap.set('n', 'gd', "<cmd>TroubleToggle lsp_definitions<cr>", bufopts)                                       -- Jump to definitions
        vim.keymap.set('n', 'gr', "<cmd>TroubleToggle lsp_references<cr>", bufopts)                                        -- Show symbol references
        vim.keymap.set('n', 'gi', "<cmd>TroubleToggle lsp_implementations<cr>", bufopts)                                   -- Show implementations
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)                                                               -- Show hover information
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)                                                  -- Show information about signature
        vim.keymap.set('n', 'rn', vim.lsp.buf.rename, bufopts)                                                             -- Rename symbol
        vim.keymap.set('n', '<space><space>', vim.lsp.buf.code_action, bufopts)                                            -- Run code actions
        vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format({ async = true }) end, bufopts)                      -- Run formatter
        vim.keymap.set('n', '<space>c', vim.lsp.buf.code_action, bufopts)                                                  -- Run code action
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)                                        -- Add workspace folder
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)                                     -- Remove workspace folder
        vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts) -- List workspace folders
      end

      -- Merge the provided `settings` with `options` and construct an LSP object
      local lspconfig = require('lspconfig')
      function languageServer(name, settings)
        flags = { on_attach = options }
        for key,value in pairs(settings) do flags[key] = value end
        lspconfig[name].setup(require('coq').lsp_ensure_capabilities(flags))
      end

      -- Language servers. For a list of available options see the documentation:
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

      languageServer("rnix", {
        cmd = { "${pkgs.rnix-lsp}/bin/rnix-lsp" },
        filetypes = { "nix" }
      })
      -- Nil is a much better language server, but formatting doesn't seem to work just yet
      --languageServer("nil_ls", {
      --  cmd = { "''${pkgs.nil-language-server}/bin/nil" },
      --  filetypes = { "nix" },
      --  settings = {
      --    formatting = {
      --      command = "''${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt"
      --    }
      --  }
      --})

      languageServer("bashls", {
        cmd = { "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server", "start" },
        filetypes = { "sh" }
      })

      languageServer("rust_analyzer", {
        cmd = { "${pkgs.rust-analyzer}/bin/rust-analyzer" },
        filetypes = { "rust" }
      })

      languageServer("clangd", {
        cmd = {
          "${pkgs.clang-tools_14}/bin/clangd",
          "--background-index",
          "--suggest-missing-includes",
          "--completion-style=detailed",
          "--compile-commands-dir=build",
          "--clang-tidy"
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        capabilities = {
          offsetEncoding = "utf-8"
        }
      })

      languageServer("cmake", {
        cmd = { "${pkgs.cmake-language-server}/bin/cmake-language-server" },
        filetypes = { "cmake" },
        init_options = {
          buildDirectory = "build"
        }
      })

      languageServer("sumneko_lua", {
        cmd = { "${pkgs.sumneko-lua-language-server}/bin/lua-language-server" },
        filetypes = { "lua" },
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT'
            },

            diagnostics = {
              globals = { 'vim' }
            },

            workspace = {
              library = vim.api.nvim_get_runtime_file("", true)
            },

            telemetry = {
              enable = false
            }
          }
        }
      })

      languageServer("pylsp", {
        cmd = { "${pkgs.python3Packages.python-lsp-server}/bin/pylsp" },
        filetypes = { "python" },
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                ignore = {
                  "E201", -- Whitespace after opening bracket
                  "E202", -- Whitespace before closing bracket
                  "E302", -- Two newlines after imports
                  "E305", -- Two newlines after class/function
                  "E501"  -- Line too long
                }
              }
            }
          }
        }
      })
    '';
  };
}
