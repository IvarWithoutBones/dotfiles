local function binding(key, action, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, key, action, { noremap = true, silent = true })
end

local builtin = require 'telescope.builtin'
local options = require 'telescope.themes'.get_ivy {}

-- Apply the options and run a picker
local function pick(picker)
    builtin[picker](options)
end

binding("<space>s", function() pick('lsp_dynamic_workspace_symbols') end)
binding("<space>tg", function() pick('live_grep') end)
binding("<space>tk", function() pick('find_files') end)
binding("<space>tb", function() pick('buffers') end)
binding("<space>tr", function() pick('resume') end) -- resume previous search

-- Git
binding("<space>gs", function() pick('git_status') end)
binding("<space>gb", function() pick('git_branches') end)
binding("<space>gc", function() pick('git_commits') end)
