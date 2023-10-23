local function binding(key, action, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, key, action, {
        noremap = true, silent = true,
    })
end

-- Disable highlight of current context by indent-blankline when beginning a motion
vim.api.nvim_create_autocmd('User', {
    pattern = 'LeapEnter',
    callback = function()
        vim.cmd("IBLDisable")
    end
})
vim.api.nvim_create_autocmd('User', {
    pattern = 'LeapLeave',
    callback = function()
        vim.cmd("IBLEnable")
    end
})

-- Bidirectional and cross-split search
local function searchAnywhere()
    require("leap").leap { target_windows = vim.tbl_filter(
        function(win) return vim.api.nvim_win_get_config(win).focusable end,
        vim.api.nvim_tabpage_list_wins(0)
    ) }

    -- For some reason insert mode is entered after the search sometimes
    vim.cmd('stopinsert')
end

binding('s', function() searchAnywhere() end)
binding('s', function() searchAnywhere() end, 'v')

-- Fade the background while doing a motion, this makes it easier to see the labels
vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
