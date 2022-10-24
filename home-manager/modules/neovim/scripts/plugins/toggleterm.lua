require "toggleterm".setup {
    direction = "horizontal",
    size = 10,
}

-- Toggle the terminal from any mode, and allow opening multiple with a number prefix
for _, mode in ipairs({ "n", "t", "i" }) do
    vim.api.nvim_set_keymap(mode, "<A-t>", "<cmd>exe v:count1 . 'ToggleTerm'<cr>", { noremap = true, silent = true })
end
