local trouble = require("trouble")

-- Dont open diagnostics window if none are found
local function showDiagnostics(currentBuffer)
    currentBuffer = currentBuffer or false
    local amount = #vim.diagnostic.get(currentBuffer and 0 or nil)
    if amount == 0 then
        print("no diagnostics found" .. (currentBuffer and " in current buffer" or ""))
    else
        trouble.toggle(currentBuffer and "document_diagnostics" or "workspace_diagnostics")
    end
end

trouble.setup {
    use_diagnostic_signs = true,
}

-- TODO: optimally these should only be loaded when the LSP is attached, but defining plugins separately is nice
local bufopts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>a', function() showDiagnostics(false) end, bufopts)           -- Show diagnostics in workspace
vim.keymap.set('n', '<space>A', function() showDiagnostics(true) end, bufopts)            -- Show diagnostics in current buffer
vim.keymap.set('n', 'gd', function() trouble.toggle("lsp_definitions") end, bufopts)      -- Jump to definitions (if there are multiple, show a list)
vim.keymap.set('n', 'gD', function() trouble.toggle("lsp_type_definitions") end, bufopts) -- Jump to type definitions (if there are multiple, show a list)
vim.keymap.set('n', 'gr', function() trouble.toggle("lsp_references") end, bufopts)       -- Show symbol references
vim.keymap.set('n', 'K', function() trouble.toggle("lsp_implementations") end, bufopts)   -- Show implementations
