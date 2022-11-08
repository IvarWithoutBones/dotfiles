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

-- Switch to the matching .cpp/.h file for C++
vim.api.nvim_create_autocmd("FileType", {
    pattern = "cpp",
    callback = function()
        vim.keymap.set('n', 'gh', function()
            local function pathInfo(path)
                path = vim.fs.normalize(path)
                return {
                    filenameWithoutExtension = path:match("([^/\\]+)%.%w+$"),
                    fileExtension = path:match("%.([^/\\]+)$"),
                    directory = vim.fs.dirname(path)
                }
            end

            local buffer = pathInfo(vim.api.nvim_buf_get_name(0))
            local friendName = buffer.filenameWithoutExtension ..
                (buffer.fileExtension == "cpp" and ".h" or ".cpp")

            for name, type in vim.fs.dir(buffer.directory) do
                if type == "file" and name == friendName then
                    local friendPath = buffer.directory .. "/" .. friendName
                    if vim.fn.filereadable(friendPath) == 1 then
                        vim.cmd("edit " .. friendPath)
                        return
                    end
                end
            end

            vim.notify("No matching .h/.cpp file found", vim.log.levels.WARN)
        end, { buffer = 0, noremap = true, silent = true })
    end
})
