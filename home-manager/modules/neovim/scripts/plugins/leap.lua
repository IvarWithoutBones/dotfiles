local function binding(key, action, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, key, action, {
        noremap = true, silent = true,
    })
end

-- Disable highlight of current context by indent-blankline when beginning a motion
local indentLineColors = {}
vim.api.nvim_create_autocmd('User', {
    pattern = 'LeapEnter',
    callback = function()
        indentLineColors = vim.api.nvim_get_hl_by_name("IndentBlanklineContextChar", true)
        -- Set the highlight to be the same as unselected contexts
        vim.api.nvim_set_hl(0, 'IndentBlanklineContextChar', { link = 'IndentBlanklineChar' })
    end
})
vim.api.nvim_create_autocmd('User', {
    pattern = 'LeapLeave',
    callback = function()
        -- Restore the old highlight
        vim.api.nvim_set_hl(0, 'IndentBlanklineContextChar', indentLineColors)
    end
})

local leap = require 'leap'

-- Bidirectional and cross-split search
local function searchAnywhere()
    leap.leap { target_windows = vim.tbl_filter(function(win)
        return vim.api.nvim_win_get_config(win).focusable
    end, vim.api.nvim_tabpage_list_wins(0)) }

    -- For some reason insert mode is entered after the search sometimes
    vim.cmd('stopinsert')
end

binding('s', function() searchAnywhere() end)
binding('s', function() searchAnywhere() end, 'v')

-- Fade the background while doing a motion, this makes it easier to see the labels
vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
