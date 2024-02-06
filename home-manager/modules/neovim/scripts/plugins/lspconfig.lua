local function languageServers()
    -- For a list of available options see the documentation:
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    local default = {
        bashls = {},    -- Bash
        glslls = {},    -- GLSL
        html = {},      -- HTML
        omnisharp = {}, -- C#
        taplo = {},     -- TOML
        tsserver = {},  -- TypeScript/JavaScript

        -- Rust
        rust_analyzer = {
            settings = {
                ["rust-analyzer"] = {
                    checkOnSave = { command = "clippy" },
                    -- Dont show diagnostics for inactive cfg directives
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

    return vim.tbl_deep_extend("force", default, loadOverrides())
end

local options = {
    -- Use nvim-cmp's capabilities, see `plugins/cmp.lua`
    capabilities = require("cmp_nvim_lsp").default_capabilities(),

    -- Configure some keybindings when a language server attaches
    on_attach = function(_, buffer)
        local function binding(key, action, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, key, action, {
                buffer = buffer,
                noremap = true,
                nowait = true,
            })
        end

        -- Format the current buffer
        binding('<space>f', function()
            vim.lsp.buf.format({ async = true })
        end)

        -- Show information about function signature
        binding('<C-k>', vim.lsp.buf.signature_help)
        binding('<C-k>', vim.lsp.buf.signature_help, 'i')

        binding('K', vim.lsp.buf.hover)                    -- Show hover information
        binding('rn', vim.lsp.buf.rename)                  -- Rename symbol
        binding('<space><space>', vim.lsp.buf.code_action) -- Code actions
    end
}

-- Register all language servers, overwriting any previous registrations
for server_name, server_options in pairs(languageServers()) do
    local merged = vim.tbl_deep_extend("force", options, server_options)
    require("lspconfig")[server_name].setup(merged)
end

--[[
    General LSP styling, also useful without lspconfig
]]

-- Replace some diagnostic icons with our own
local icons = {
    Error = "",
    Warn = "",
    Hint = "",
    Info = ""
}

for type, icon in pairs(icons) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Rounded corners for popup boxes
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = 'rounded'
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
