require("trouble").setup {
    warn_no_results = false, -- The warning requires you to press enter to confirm, which is a annoying
    auto_jump = true,        -- Dont show the picker if there is only one result
    focus = true,            -- Automatically focus the buffer

    modes = {
        diagnostics = {
            -- Sort by position first so that related diagnostics are more closely grouped together
            sort = { "pos", "severity", "filename", "message" },
            -- Disable the separate directory fold
            groups = { { "filename", format = "{file_icon} {filename} {count}" } },
        },
    },

    keys = {
        ["<cr>"] = "jump_close", -- Close the menu and jump to the selected item
        o = "jump",              -- Jump to the selected item
        L = "fold_open",         -- Open the fold closest to the cursor
        H = "fold_close",        -- Close the fold closest to the cursor
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
bind("gd", "lsp_definitions")
bind("gD", "lsp_type_definitions")
bind("gr", "lsp_references")
bind("gi", "lsp_implementations")
