-- General LSP styling

local icons = {
    Error = "",
    Warn = "",
    Hint = "",
    Info = ""
}

-- Replace some diagnostic icons with our own
for type, icon in pairs(icons) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
    update_in_insert = true, -- Update diagnostics in insert mode
    severity_sort = true,    -- Sort diagnostics by severity
})

-- Rounded corners for popup boxes
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = 'rounded'
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
