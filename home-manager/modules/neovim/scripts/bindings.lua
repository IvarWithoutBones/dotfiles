local function map(mode, shortcut, command)
    vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end

local function nmap(shortcut, command)
    map("n", shortcut, command)
end

local function imap(shortcut, command)
    map("i", shortcut, command)
end

local function tmap(shortcut, command)
    map("t", shortcut, command)
end

-- Fixes space mappings
nmap("<SPACE>", "<Nop>")

-- Insert a newline without going into insert mode
nmap("<Enter>", "o<Esc>")

-- use `Alt+Shift+{h,j,k,l}` to resize splits
nmap("<A-J>", ":resize +2<CR>")
nmap("<A-K>", ":resize -2<CR>")
nmap("<A-L>", ":vertical resize +2<CR>")
nmap("<A-H>", ":vertical resize -2<CR>")

-- use `ALT+{h,j,k,l}` to navigate windows from any mode
for _, key in ipairs({ "h", "j", "k", "l" }) do
    nmap("<A-" .. key .. ">", "<C-w>" .. key)
    tmap("<A-" .. key .. ">", "<C-\\><C-N><C-w>" .. key)
    imap("<A-" .. key .. ">", "<C-\\><C-N><C-w>" .. key)
end

-- Find and replace a string in the current buffer based on user input
nmap("<A-f>", ":luafile @findAndReplace@<cr>")
