-- Disable highlight of current context when beginning a leap.nvim motion
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

require("indent_blankline").setup {
    show_current_context = true,
    space_char_blankline = " ",
}
