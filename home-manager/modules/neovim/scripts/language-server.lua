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
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover, { border = 'rounded' }
)
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help, { border = 'rounded' }
)

-- Code actions
vim.g.code_action_menu_show_details = false
vim.g.code_action_menu_window_border = 'rounded'

-- Interactive diagnostics
require("trouble").setup {
    auto_close = true,
    use_diagnostic_signs = true,
}

-- Completion
vim.g.coq_settings = {
    auto_start = 'shut-up', -- Load the completion engine on startup
    xdg = true, -- Dont try to install dependencies to the nix store
    ["clients.lsp.always_on_top"] = {}, -- Always show LSP completions above other sources
    ["display.pum.fast_close"] = false, -- Stops some flickering
    ["keymap.manual_complete"] = '<C-c>', -- Manually trigger completion
}

-- Mappings. See `:help vim.lsp.*` for documentation on the below functions
local options = function(_, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', '<space>A', "<cmd>TroubleToggle workspace_diagnostics<cr>", bufopts) -- Open all diagnostics
    vim.keymap.set('n', '<space>a', "<cmd>TroubleToggle document_diagnostics<cr>", bufopts) -- Open document diagnostics
    vim.keymap.set('n', 'gD', "<cmd>TroubleToggle lsp_type_definitions<cr>", bufopts) -- Jump to type definitions
    vim.keymap.set('n', 'gd', "<cmd>TroubleToggle lsp_definitions<cr>", bufopts) -- Jump to definitions
    vim.keymap.set('n', 'gr', "<cmd>TroubleToggle lsp_references<cr>", bufopts) -- Show symbol references
    vim.keymap.set('n', 'gi', "<cmd>TroubleToggle lsp_implementations<cr>", bufopts) -- Show implementations
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts) -- Show hover information
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts) -- Show information about signature
    vim.keymap.set('n', 'rn', vim.lsp.buf.rename, bufopts) -- Rename symbol
    vim.keymap.set('n', '<space><space>', "<cmd>CodeActionMenu<cr>", bufopts) -- Run code actions
    vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format({ async = true }) end, bufopts) -- Run formatter
    vim.keymap.set('n', '<space>c', vim.lsp.buf.code_action, bufopts) -- Run code action
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts) -- Add workspace folder
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts) -- Remove workspace folder
    vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts) -- List workspace folders
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
