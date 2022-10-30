local function binding(key, action, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, key, action, { noremap = true, silent = true })
end

local builtin = require('telescope.builtin')

require('telescope').setup {
    theme = "ivy"
}

binding("<space>s", builtin.lsp_dynamic_workspace_symbols)
binding("tg", builtin.live_grep)
binding("tk", builtin.find_files)
binding("tb", builtin.buffers)
binding("tr", builtin.resume) -- Resume last search

-- Git
binding("tgs", builtin.git_status)
binding("tgb", builtin.git_branches)
binding("tgc", builtin.git_commits)
