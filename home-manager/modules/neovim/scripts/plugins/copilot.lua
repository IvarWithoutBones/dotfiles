-- Accept completions using Control+J instead of tab
vim.g.copilot_no_tab_map = true
vim.keymap.set("i", "<C-J>", "copilot#Accept(\"\\<CR>\")", {
    expr = true,
    replace_keycodes = false,
    silent = true,
})
