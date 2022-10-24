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

-- Disable insertion of a comment when creating a newline if the current line has one.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
})
