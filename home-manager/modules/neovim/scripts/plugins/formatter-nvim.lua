require("formatter").setup {
    filetype = {
        sh = function()
            return {
                exe = "@shfmt@",
                stdin = true,
                args = {
                    "--binary-next-line",
                    "--space-redirects",
                    "--case-indent",
                    "--simplify",
                }
            }
        end
    },
}

-- Overwrite the LSP's keybind if the server does not support formatting
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        local buffer = vim.api.nvim_get_current_buf()

        local clients = vim.lsp.get_active_clients({ bufnr = buffer })
        for _, client in ipairs(clients) do
            if client.supports_method("textDocument/formatting") then
                return
            end
        end

        vim.keymap.set("n", "<space>f", ":Format<CR>", {
            buffer = buffer,
            noremap = true,
            silent = true,
            nowait = true,
        })
    end
})
