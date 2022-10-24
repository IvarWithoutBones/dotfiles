require('lualine').setup {
    options = {
        theme = "catppuccin",
        ignore_focus = {
            "NvimTree",
            "toggleterm",
            "TelescopePrompt"
        }
    }
}

-- Dont show 'INSERT', the statusline already takes care of it
vim.cmd("set noshowmode")
