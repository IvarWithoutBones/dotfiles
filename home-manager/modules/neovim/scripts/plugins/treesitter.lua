require 'nvim-treesitter.configs'.setup {
    highlight = {
        enable = true,
        disable = {
            'nix' -- Doesn't look very good
        },
    },

    indent = {
        enable = true,
    },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gn",
            scope_incremental = "gs",
            node_incremental = "gl",
            node_decremental = "gh",
        },
    },
}
