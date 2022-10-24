require 'nvim-tree'.setup {
    update_focused_file = {
        enable = true,
        update_cwd = true,
    },

    filters = {
        dotfiles = false,
    },

    renderer = {
        group_empty = true,
    },

    view = {
        signcolumn = "no",
    },
}

vim.keymap.set('n', '<c-b>', "<cmd>NvimTreeToggle<cr>", { noremap = true, silent = true })
