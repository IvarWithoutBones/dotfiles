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
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Rounded corners for popup boxes
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = 'rounded'
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Completion
vim.g.coq_settings = {
    auto_start = 'shut-up', -- Load the completion engine on startup
    ["display.pum.fast_close"] = false, -- Stops some flickering
    ["keymap.manual_complete"] = '<C-c>', -- Manually trigger completion

    clients = {
        -- Show paths based on file instead of working directory
        ["paths.resolution"] = { "file" },

        -- These effect the ordering of completion
        ["lsp.weight_adjust"] = 1.4,
        ["buffers.weight_adjust"] = 0.8,
    },
}

-- Bindings
local options = function(client, buffer)
    local function binding(key, action, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, key, action, {
            buffer = buffer,
            noremap = true,
            nowait = true,
        })
    end

    if client.supports_method("textDocument/formatting") then
        binding('<space>f', function()
            vim.lsp.buf.format({ async = true })
        end)
    end

    -- Show information about function signature
    binding('<C-k>', vim.lsp.buf.signature_help)
    binding('<C-k>', vim.lsp.buf.signature_help, 'i')

    binding('K', vim.lsp.buf.hover) -- Show hover information
    binding('rn', vim.lsp.buf.rename) -- Rename symbol
    binding('<space><space>', vim.lsp.buf.code_action) -- Code actions

    -- Workspace manipulation
    binding('<space>wa', vim.lsp.buf.add_workspace_folder) -- Add workspace folder
    binding('<space>wr', vim.lsp.buf.remove_workspace_folder) -- Remove workspace folder
    binding('<space>wl', function() -- List workspace folders
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end)
end

-- Merge the provided `settings` with extra `options` and construct an LSP object
local function mkLanguageServer(name, settings)
    local flags = { on_attach = options }
    for key, value in pairs(settings) do flags[key] = value end
    require('lspconfig')[name].setup(require('coq').lsp_ensure_capabilities(flags))
end

-- languageServers are generated from the nix expression that imports this file
for name, settings in pairs({ @languageServers@ }) do
    mkLanguageServer(name, settings)
end
