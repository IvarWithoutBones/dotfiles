require("ibl").setup({
    scope = {
        show_exact_scope = true,
        show_start = false,
        show_end = false,

        -- Configure scopes to highlight for languages where treesitter is unable to
        include = {
            node_type = {
                lua = { "return_statement", "table_constructor" },
                nix = { "*" },
            },
        },
    },
})
