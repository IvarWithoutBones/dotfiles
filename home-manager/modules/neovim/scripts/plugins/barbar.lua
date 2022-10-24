local function map(key, cmd)
    vim.api.nvim_set_keymap('n', key, cmd, { noremap = true, silent = true })
end

require 'bufferline'.setup {
    animation = false,
    insert_at_end = true,
    icon_pinned = '',
}

-- Move to the previous and next
map('<A-,>', '<cmd>BufferPrevious<cr>')
map('<A-.>', '<cmd>BufferNext<cr>')

-- Re-order the previous and next
map('<A-<>', '<cmd>BufferMovePrevious<cr>')
map('<A->>', '<cmd>BufferMoveNext<cr>')

-- Close and force close
map('<A-q>', '<cmd>BufferClose<cr>')
map('<A-Q>', '<cmd>BufferClose!<cr>')

-- Pin or unpin
map('<A-p>', '<cmd>BufferPin<cr>')

-- Close all but the current and pinned
map('<A-x>', '<cmd>BufferCloseAllButCurrentOrPinned<cr>')

-- Sort all by directory
map('<A-s>', '<cmd>BufferOrderByDirectory<cr>')

-- Jump by label
map('<A-b>', '<cmd>BufferPick<cr>')

-- Jump by position
for itr = 1, 9 do
    map('<A-' .. itr .. '>', '<cmd>BufferGoto ' .. itr .. '<cr>')
end
map('<A-0>', '<cmd>BufferLast<cr>')
