-- Returns the function signature at the current cursor position, requires the `lsp_signature` plugin
local function signature_hint()
    local sig = require("lsp_signature").status_line()
    local text
    -- Insert a symbol before the function argument the cursor is currently hovering on, if it has any arguments
    if (sig.range['end'] - sig.range.start) ~= 0 then
        text = sig.label:sub(1, sig.range.start - 1) .. " " .. sig.label:sub(sig.range.start)
    else
        text = sig.label
    end

    -- If the label is bigger than half of our total width, truncate it while centering the argument under the cursor
    -- This is needed to avoid overflowing into other sections with a sufficiently small window.
    local max_width = vim.fn.winwidth(0) / 2
    if #text > max_width then
        local start = math.max(1, sig.range.start - (max_width / 4))
        local start_trunc -- Prefix string indicating if we truncated the start
        if start ~= 1 then start_trunc = "󰇘 " else start_trunc = "" end

        local end_ = start + (max_width - (start / 2))
        local end_trunc -- Postfix string indicating if we truncated the end
        if end_ < #text then end_trunc = " 󰇘" else end_trunc = "" end

        return start_trunc .. string.sub(text, start, end_) .. end_trunc
    else
        return text
    end
end

require('lualine').setup {
    options = {
        theme = "catppuccin",
        component_separators = '|',
        section_separators = { left = '', right = '' },
        refresh = { statusline = 200, }, -- In milliseconds
        ignore_focus = {
            "NvimTree",
            "toggleterm",
            "TelescopePrompt"
        }
    },

    sections = {
        lualine_a = {
            { 'mode', separator = { left = '' }, right_padding = 2 },
        },
        lualine_b = { 'diagnostics' },
        lualine_c = {
            { signature_hint, color = { fg = "#a6adc8" } }
        },
        lualine_x = {},
        lualine_y = { 'branch', 'diff' },
        lualine_z = {
            { 'filetype', colored = false, separator = { right = '' } },
        },
    }
}

-- Dont show the mode indicator as statusline already takes care of it
vim.cmd("set noshowmode")
