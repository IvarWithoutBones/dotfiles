-- Loads a table from `.lspconfig.json` in the current working directory, if it exists.
-- This is used for per-project overrides of the default LSP configurations, for example to enable Cargo features:
-- ```json
-- {"rust_analyzer":{"settings":{"rust-analyzer":{"cargo":{"features":["foo"]}}}}}
-- ```
local function loadOverrides()
    local path = vim.fs.normalize(vim.fn.getcwd() .. "/.lspconfig.json")
    local err_prefix = "Error loading lspconfig override (" .. path .. "): "
    local file = io.open(path)
    if not file then
        return {} -- File most likely does not exit, do nothing
    end

    local is_ok, value = pcall(vim.json.decode, file:read("*all"))
    if not is_ok then
        vim.print(err_prefix .. value)
        return {}
    end
    if type(value) ~= "table" then
        vim.print(err_prefix .. "Expected a table, got " .. type(value))
        return {}
    end

    vim.print("Loaded lspconfig override from " .. path)
    return value
end

local function loadLanguageServers()
    -- For a list of available options see the documentation:
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    local default = {
        bashls = {},    -- Bash
        glslls = {},    -- GLSL
        html = {},      -- HTML
        omnisharp = {}, -- C#
        taplo = {},     -- TOML
        ts_ls = {},     -- TypeScript/JavaScript

        -- Rust
        rust_analyzer = {
            settings = {
                ["rust-analyzer"] = {
                    files = {
                        exclude = {
                            -- Ignore all files/directories that contain symlinks to the nix store, as that seemingly causes rust-analyzer to scan the entire store:
                            -- https://github.com/rust-lang/rust-analyzer/issues/14734#issuecomment-2373988391
                            ".direnv",
                            "result",
                            "result-dev",
                            "result-man",
                            "result-out",
                        }
                    },

                    -- Show diagnostics from `cargo clippy` instead of `cargo check`. The former is a bit stricter.
                    checkOnSave = { command = "clippy" },

                    -- Don't show diagnostics for inactive cfg directives.
                    diagnostics = { disabled = { "inactive-code" } },
                }
            }
        },

        -- C/C++/Objective-C
        clangd = {
            capabilities = { offsetEncoding = "utf-8" },
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--all-scopes-completion",
                "--header-insertion=iwyu",
                "--suggest-missing-includes",
                "--completion-style=detailed",
                "--compile-commands-dir=build",
                "--fallback-style=llvm"
            }
        },

        -- CMake
        cmake = {
            init_options = { buildDirectory = "build" }
        },

        -- JSON
        jsonls = {
            -- lspconfig expects "vscode-json-language-server", but nixpkgs provides it under a different name
            cmd = { "vscode-json-languageserver", "--stdio" }
        },

        -- Nix
        nil_ls = {
            settings = {
                ["nil"] = {
                    formatting = { command = { "nixpkgs-fmt" } }
                }
            }
        },

        -- Lua
        lua_ls = {
            settings = {
                Lua = {
                    diagnostics = { globals = { "vim" } },
                    runtime = { version = "LuaJIT" },
                    telemetry = { enable = false }
                }
            }
        },

        -- Python
        pylsp = {
            settings = {
                pylsp = {
                    plugins = {
                        pycodestyle = {
                            ignore = {
                                "E201", -- Whitespace after opening bracket
                                "E202", -- Whitespace before closing bracket
                                "E302", -- Two newlines after imports
                                "E305", -- Two newlines after class/function
                                "E501", -- Line too long
                            }
                        }
                    }
                }
            }
        },

        -- YAML
        yamlls = {
            settings = {
                redhat = {
                    telemetry = { enabled = false }
                }
            }
        }
    }

    return vim.tbl_deep_extend("force", default, loadOverrides())
end

local function binding(buffer, key, action, opts)
    opts = opts or {}
    local keymapOpts = {
        buffer = buffer,
        noremap = true,
        nowait = true,
    }
    if opts.desc then keymapOpts.desc = opts.desc end
    vim.keymap.set(opts.mode or "n", key, action, keymapOpts)
end

local function commonBindings(buffer)
    -- Format the current buffer
    binding(buffer, '<space>f', function()
        vim.lsp.buf.format({ async = true })
    end)

    -- Show information about function signature
    binding(buffer, '<C-k>', vim.lsp.buf.signature_help)
    binding(buffer, '<C-k>', vim.lsp.buf.signature_help, { mode = 'i' })

    binding(buffer, 'K', vim.lsp.buf.hover)                    -- Show hover information
    binding(buffer, 'rn', vim.lsp.buf.rename)                  -- Rename symbol
    binding(buffer, '<space><space>', vim.lsp.buf.code_action) -- Code actions
end


local options = {
    -- Use nvim-cmp's capabilities, see `plugins/cmp.lua`
    capabilities = require("cmp_nvim_lsp").default_capabilities(),

    -- Configure some keybindings when a language server attaches
    on_attach = function(_, buffer)
        commonBindings(buffer)
    end
}

-- Cache the language server configurations (with overrides applied) so that rustaceanvim can use them as well
local languageServers = loadLanguageServers()

-- Register all language servers, overwriting any previous registrations
for server_name, server_options in pairs(languageServers) do
    -- Ignore rust-analyzer, its configured separately via rustaceanvim
    if server_name ~= "rust_analyzer" then
        local merged = vim.tbl_deep_extend("force", options, server_options)
        require("lspconfig")[server_name].setup(merged)
    end
end

-- Configure rustaceanvim, which initialises rust-analyzer differently from other LSP clients
vim.g.rustaceanvim = {
    tools = {
        executor = require('rustaceanvim.executors').toggleterm,
        test_executor = require('rustaceanvim.executors').toggleterm
    },
    server = {
        settings = languageServers.rust_analyzer.settings,

        -- Configure some rust-specific keybindings when the language server attaches
        on_attach = function(_, buffer)
            commonBindings(buffer)
            -- Open the parent module
            binding(buffer, 'gp', function() vim.cmd.RustLsp('parentModule') end, { desc = "open parent module" })
            -- Open Cargo.toml
            binding(buffer, 'gP', function() vim.cmd.RustLsp('openCargo') end, { desc = "open Cargo.toml" })
            -- Recursively expand the macro under the cursor
            binding(buffer, '<space>rm', function() vim.cmd.RustLsp('expandMacro') end, { desc = "expand macro" })
            -- Open documentation of the hovered symbol in the browser
            binding(buffer, '<space>rD', function() vim.cmd.RustLsp('openDocs') end, { desc = "open documentation" })
            -- Show diagnostics from `cargo clippy`
            binding(buffer, '<space>rd', function() vim.cmd.RustLsp('renderDiagnostic') end,
                { desc = "render diagnostics" }
            )
        end,
    }
}
