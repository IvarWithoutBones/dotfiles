require 'catppuccin'.setup {
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    integrations = {
        ['indent_blankline.enabled'] = true,
        ['native_lsp.enabled'] = true,
        lsp_trouble = true,
        telescope = true,
        leap = true,
        nvimtree = true,
        barbar = true,
        lualine = true,
        treesitter = true,
    }
}

vim.cmd("colorscheme catppuccin")
