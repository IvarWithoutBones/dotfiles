-- Dont open diagnostics window if none are found
local function showDiagnostics(currentBuffer)
    currentBuffer = currentBuffer or false
    local amount = #vim.diagnostic.get(currentBuffer and 0 or nil)
    if amount == 0 then
        print("no diagnostics found" .. (currentBuffer and " in current buffer" or ""))
    else
        vim.cmd("TroubleToggle " .. (currentBuffer and "document_diagnostics" or "workspace_diagnostics"))
    end
end

require("trouble").setup {
    auto_close = true,
    use_diagnostic_signs = true,
    auto_jump = { "lsp_definitions", "lsp_type_definitions", "lsp_references", "lsp_implementations" },
}

-- TODO: optimally these should only be loaded when the LSP is attached, but defining plugins seperately is nice
local bufopts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>a', function() showDiagnostics(false) end, bufopts) -- Show diagnostics in workspace
vim.keymap.set('n', '<space>A', function() showDiagnostics(true) end, bufopts) -- Show diagnostics in current buffer
vim.keymap.set('n', 'gd', "<cmd>TroubleToggle lsp_definitions<cr>", bufopts) -- Jump to definitions
vim.keymap.set('n', 'gD', "<cmd>TroubleToggle lsp_type_definitions<cr>", bufopts) -- Jump to type definitions
vim.keymap.set('n', 'gr', "<cmd>TroubleToggle lsp_references<cr>", bufopts) -- Show symbol references
vim.keymap.set('n', 'gi', "<cmd>TroubleToggle lsp_implementations<cr>", bufopts) -- Show implementations
