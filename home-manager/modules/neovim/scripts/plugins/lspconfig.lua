-- For a list of available options see the documentation:
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
local configurations = {
    glslls = {},    -- GLSL
    html = {},      -- HTML
    omnisharp = {}, -- C#
    taplo = {},     -- TOML
    ts_ls = {},     -- TypeScript/JavaScript

    -- Python
    basedpyright = {},
    ruff = {},

    -- Bash
    bashls = {
        settings = {
            bashIde = {
                shellcheckArguments = { "--enable=all" },
                shfmt = {
                    simplifyCode = true,
                    binaryNextLine = true,
                    caseIndent = true,
                    spaceRedirects = true,
                },
            },
        },
    },

    -- C/C++/Objective-C
    clangd = {
        cmd = {
            "clangd",
            "--clang-tidy",
            "--background-index",
            "--enable-config",
            "--fallback-style=google"
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
                telemetry = { enable = false },
                runtime = { version = "LuaJIT" },
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

local function binding(buffer, key, action, desc, mode)
    local keymapOpts = {
        buffer = buffer,
        noremap = true,
        nowait = true,
        desc = desc,
    }
    vim.keymap.set(mode or "n", key, action, keymapOpts)
end

---@param client vim.lsp.Client
---@param buf number
local function on_attach(client, buf)
    if client:supports_method("textDocument/formatting", buf) then
        local bind = "<space>f"
        if client.name == "ruff" and vim.bo[buf].filetype == "python" then
            -- When formatting using Ruff, apply its "organize imports" code action after formatting
            binding(buf, bind, function()
                vim.lsp.buf.format({ bufnr = buf, async = false })
                vim.lsp.buf.code_action({
                    apply = true,
                    context = { only = { "source.organizeImports" }, diagnostics = {} },
                })
            end, "format document and organize imports")
        else
            binding(buf, bind, function() vim.lsp.buf.format({ bufnr = buf, async = true }) end, "format document")
        end
    end

    if client:supports_method("textDocument/signatureHelp", buf) then
        binding(buf, "<C-k>", vim.lsp.buf.signature_help, "signature help", { "n", "i" })
    end

    if client:supports_method("textDocument/rename", buf) then
        binding(buf, "rn", vim.lsp.buf.rename, "rename symbol")
    end

    if client:supports_method("textDocument/codeAction", buf) then
        binding(buf, "<space><space>", vim.lsp.buf.code_action, "code actions")
    end

    if client:supports_method("textDocument/definition", buf) then
        binding(buf, "gd", function() require("trouble").toggle("lsp_definitions") end, "go to definition")
    end

    if client:supports_method("textDocument/typeDefinition", buf) then
        binding(buf, "gD", function() require("trouble").toggle("lsp_type_definitions") end, "go to type definition")
    end

    if client:supports_method("textDocument/references", buf) then
        binding(buf, "gr", function() require("trouble").toggle("lsp_references") end, "go to references")
    end

    if client:supports_method("textDocument/implementation", buf) then
        binding(buf, "gi", function() require("trouble").toggle("lsp_implementations") end, "go to implementation")
    end

    if client:supports_method("textDocument/hover", buf) then
        local bind = "K"
        if client.name == "rust-analyzer" then
            binding(buf, bind, function() vim.cmd.RustLsp({ 'hover', 'actions' }) end, "hover actions")
        else
            binding(buf, bind, vim.lsp.buf.hover, "hover")
        end
    end

    -- Rust-specific keybindings. The `RustLsp` command is provided by rustaceanvim.
    if client.name == "rust-analyzer" then
        binding(buf, "gp", function() vim.cmd.RustLsp('parentModule') end, "open parent Rust module")
        binding(buf, "gP", function() vim.cmd.RustLsp('openCargo') end, "open Cargo.toml")
        binding(buf, "<space>rd", function() vim.cmd.RustLsp('renderDiagnostic') end, "render diagnostics")

        binding(buf, "<space>rD", function() vim.cmd.RustLsp('openDocs') end,
            "open documentation of hovered symbol in browser"
        )

        binding(buf, "<space>rr", function() vim.cmd.RustLsp('runnables') end,
            "fuzzy pick and execute runnable (tests, main, ...)"
        )

        binding(buf, "<space>rR", function() vim.cmd.RustLsp('run') end,
            "execute hovered runnable (tests, main, ...)"
        )

        binding(buf, "<space>rm", function() vim.cmd.RustLsp('expandMacro') end,
            "recursively expand macro under cursor"
        )
    end
end

-- Set the LSP keybindings whenever a language server attaches
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup("lsp_attach_bindings", {}),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
            if vim.lsp.is_enabled("ruff") and vim.lsp.is_enabled("basedpyright") then
                if client.name == "ruff" then
                    -- Disable Ruff's hover capability, use BasedPyright's instead.
                    client.server_capabilities.hoverProvider = false
                elseif client.name == "basedpyright" then
                    -- Disable BasedPyright's formatting capability, use Ruff's instead.
                    client.server_capabilities.documentFormattingProvider = false
                end
            end

            on_attach(client, args.buf)
        end
    end,
})

-- Re-apply on_attach when new capabilities are registered
vim.lsp.handlers['client/registerCapability'] = (function(overridden)
    return function(err, res, ctx)
        local result = overridden(err, res, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
            for bufnr, _ in pairs(client.attached_buffers) do
                on_attach(client, bufnr)
            end
        end
        return result
    end
end)(vim.lsp.handlers['client/registerCapability'])

-- Set up capabilities for every language server
vim.lsp.config('*', {
    capabilities = vim.tbl_deep_extend("force",
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities(),
        {
            -- https://github.com/neovim/nvim-lspconfig/issues/2184#issuecomment-1574848274
            offsetEncoding = { 'utf-16' },
            general = { positionEncodings = { 'utf-16' } },
        }
    )
})

-- Configure and enable the language servers
for server_name, server_options in pairs(configurations) do
    if server_options ~= {} then
        vim.lsp.config(server_name, server_options)
    end
    vim.lsp.enable(server_name)
end
