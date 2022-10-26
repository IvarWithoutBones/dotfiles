require("trouble").setup {
    auto_close = true,
    use_diagnostic_signs = true,
}

-- TODO: optimally these should only be loaded when the LSP is attached, but defining plugins seperately is nice
local bufopts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>A', "<cmd>TroubleToggle document_diagnostics<cr>", bufopts) -- Open document diagnostics
vim.keymap.set('n', '<space>a', "<cmd>TroubleToggle workspace_diagnostics<cr>", bufopts) -- Open all diagnostics
vim.keymap.set('n', 'gD', "<cmd>TroubleToggle lsp_type_definitions<cr>", bufopts) -- Jump to type definitions
vim.keymap.set('n', 'gd', "<cmd>TroubleToggle lsp_definitions<cr>", bufopts) -- Jump to definitions
vim.keymap.set('n', 'gr', "<cmd>TroubleToggle lsp_references<cr>", bufopts) -- Show symbol references
vim.keymap.set('n', 'gi', "<cmd>TroubleToggle lsp_implementations<cr>", bufopts) -- Show implementations
