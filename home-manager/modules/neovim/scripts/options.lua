local opt = vim.opt

opt.mouse = "a" -- Mouse support
opt.clipboard = "unnamedplus" -- System clipboard support, needs xclip/wl-clipboard
vim.cmd("set ignorecase smartcase") -- Case insensitve search if no uppercase letters are present

-- Theming and UI
opt.syntax = "enable" -- Syntax highlighting
opt.termguicolors = true -- True color support
opt.cursorline = true -- Highlight current line in insert mode
opt.ruler = true -- Show line and column number when searching

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tab defaults
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 0
opt.expandtab = true
opt.smarttab = true
