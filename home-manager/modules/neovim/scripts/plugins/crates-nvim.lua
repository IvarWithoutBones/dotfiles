require('crates').setup {
    src = {
        coq = {
            -- Enable completion, requires the `coq_nvim` plugin
            enabled = true,
            name = "crates.nvim",
        },
    },

    null_ls = {
        -- Enable code actions using null-ls, requires the `null-ls-nvim` plugin
        enabled = true,
        name = "crates.nvim",
    },
}
