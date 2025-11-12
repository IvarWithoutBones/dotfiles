-- General LSP styling

local icons = {
    Error = "",
    Warn = "",
    Hint = "",
    Info = ""
}

local signs = { text = {}, linehl = {}, numhl = {} }
for type, icon in pairs(icons) do
    local severity = vim.diagnostic.severity[string.upper(type)]
    signs.text[severity] = icon
    signs.linehl[severity] = type .. "Msg"
    signs.numhl[severity] = type .. "Msg"
end

vim.diagnostic.config({
    signs = signs,                  -- Use the symbols defined above
    virtual_text = true,            -- Show diagnostics next to their source line
    update_in_insert = true,        -- Update diagnostics in insert mode
    float = { border = "rounded" }, -- Use rounded corners for floating windows
})

-- Rounded corners for popup boxes
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = 'rounded'
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
