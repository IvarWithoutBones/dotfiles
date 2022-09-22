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
        vim.lsp.handlers.hover,
        {border = 'rounded'}
      )

      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        {border = 'rounded'}
      )

      -- Coq settings
      vim.g.coq_settings = {
        auto_start = 'shut-up', -- Automatically start coq, the completion engine
        xdg = true, -- Dont try to install dependencies to the nix store
        ["display.pum.fast_close"] = false -- Stops some flickering
      }

      -- Mappings. See `:help vim.lsp.*` for documentation on the below functions
      local options = function(client, bufnr)
        local bufopts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', '<space>a', "<cmd>TroubleToggle workspace_diagnostics<cr>", bufopts) -- Open a list with all diagnostics
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)                     -- Jump to declaration
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)                      -- Jump to definition
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)                            -- Show hover information
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)                  -- Show implementation (?)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)                      -- Show symbol references. TODO: make interactive
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)               -- Show information about signature
        vim.keymap.set('n', '<space>d', vim.lsp.buf.type_definition, bufopts)           -- Jump to type definition
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)                   -- Rename symbol
        vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)                -- Run formatter
        vim.keymap.set('n', '<space>c', vim.lsp.buf.code_action, bufopts)               -- Run code action
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)     -- Add workspace folder
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)  -- Remove workspace folder
        vim.keymap.set('n', '<space>wl', function()                                     -- List workspace folders
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
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

      languageServer("bashls", {
        cmd = { "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server", "start" },
        filetypes = { "sh" }
      })

      languageServer("rust_analyzer", {
        cmd = { "${pkgs.rust-analyzer}/bin/rust-analyzer" },
        filetypes = { "rust" }
      })

      languageServer("ccls", {
        cmd = { "${pkgs.ccls}/bin/ccls" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        offset_encoding = "utf-8",
        init_options = {
          compilationDatabaseDirectory = "build"
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
