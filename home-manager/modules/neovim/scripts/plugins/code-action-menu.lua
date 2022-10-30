vim.g.code_action_menu_show_details = false
vim.g.code_action_menu_window_border = 'rounded'

local bufoptions = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<space><space>", "<cmd>CodeActionMenu<cr>", bufoptions)
