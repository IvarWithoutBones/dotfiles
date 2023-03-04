require('lualine').setup {
    options = {
        theme = "catppuccin",
        component_separators = '|',
        section_separators = { left = '', right = '' },
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
        lualine_b = { "filename", 'diagnostics' },
        lualine_c = { 'branch', 'diff' },
        lualine_x = {},
        lualine_y = { 'progress' },
        lualine_z = {
            { 'filetype', separator = { right = '' }, left_padding = 2 },
        },
    },
}

-- Dont show the mode indicator as statusline already takes care of it
vim.cmd("set noshowmode")
