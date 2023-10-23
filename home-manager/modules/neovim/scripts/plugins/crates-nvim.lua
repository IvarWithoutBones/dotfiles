require('crates').setup {
    src = {
        -- Enable completion, requires the `nvim-cmp` plugin
        cmp = {
            enabled = true,
        },
    },

    null_ls = {
        -- Enable code actions using null-ls, requires the `null-ls-nvim` plugin
        enabled = true,
        name = "crates.nvim",
    },
}
