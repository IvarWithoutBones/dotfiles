-- Automatically change the working directory to a git repository's root
vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
        local gitRoot = vim.fn.system("@git@ rev-parse --show-toplevel 2>/dev/null")
        if (gitRoot ~= nil and gitRoot ~= "") then
            vim.cmd("cd " .. gitRoot)
        end
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        -- Disable insertion of a comment when creating a newline if the current line has one
        vim.cmd("setlocal formatoptions-=c formatoptions-=r formatoptions-=o")

        -- Use tab indentation size from the language server, if available
        vim.opt.tabstop = vim.lsp.util.get_effective_tabstop()
    end
})
