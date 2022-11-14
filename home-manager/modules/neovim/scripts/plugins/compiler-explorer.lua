require "compiler-explorer".setup({
    url = "https://godbolt.org",
    job_timeout = 25000,

    autocmd = {
        enable = true,
        hl = "Cursorline",
    },

    diagnostics = {
        underline = true,
        virtual_text = true,
        signs = true,
    },
})
