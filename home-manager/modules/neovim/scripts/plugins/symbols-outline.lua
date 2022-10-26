require "symbols-outline".setup {
    preview_bg_highlight = "NormalFloat",
    border = "rounded",
    keymaps = {
        -- Match other LSP settings
        code_actions = "<space><space>",
        toggle_preview = "<C-k>",
        hover_symbol = "K",
        rename_symbol = "rn",
    }
}

local bufoptions = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<space>s", "<cmd>SymbolsOutline<cr>", bufoptions)
