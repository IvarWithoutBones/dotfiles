require("trouble").setup {
    warn_no_results = false, -- The warning requires you to press enter to confirm, which is a annoying
    focus = true,            -- Automatically focus the buffer

    modes = {
        diagnostics = {
            -- Sort by position first so that related diagnostics are more closely grouped together
            sort = { "pos", "severity", "filename", "message" },
            -- Disable the separate directory fold
            groups = { { "filename", format = "{file_icon} {filename} {count}" } },
        },

        symbols = {
            win = { size = 40, },
            groups = {}, -- Do not group symbols under their filename, the window only ever shows the current file.
            format = "{kind_icon} {symbol.name} {text:Comment}",
        },
    },

    keys = {
        o = "jump_close", -- Jump to the selected item and close the menu
        L = "fold_open",  -- Open the fold closest to the cursor
        H = "fold_close", -- Close the fold closest to the cursor
    }
}

local function bind(key, mode, opts, action)
    local args = vim.tbl_deep_extend("force", { mode = mode }, opts or {})
    local func = action or "toggle"
    local keyOpts = { noremap = true, silent = true }
    vim.keymap.set("n", key, function() require("trouble")[func](args) end, keyOpts)
end

bind("<space>a", "diagnostics")
bind("<space>A", "diagnostics", { focus = false })
bind("<space>S", "symbols")
bind("gd", "lsp_definitions")
bind("gD", "lsp_type_definitions")
bind("gr", "lsp_references")
bind("gi", "lsp_implementations")
