local function map(key, cmd)
    local binding = '<cmd>' .. cmd .. '<cr>'
    vim.api.nvim_set_keymap('n', key, binding, { noremap = true, silent = true })
end

vim.g.barbar_auto_setup = false -- Disable auto-setup so we can supply our own config

require 'bufferline'.setup {
    animation = false,
    tabpages = false,
    insert_at_end = true,

    icons = {
        separator_at_end = false,
        pinned = { button = '' },
    }
}

-- Move to the previous and next
map('<A-[>', 'BufferPrevious')
map('<A-]>', 'BufferNext')

-- Re-order the previous and next
map('<A-<>', 'BufferMovePrevious')
map('<A->>', 'BufferMoveNext')

-- Close and restore
map('<A-q>', 'BufferClose')
map('<A-s-q>', 'BufferRestore')
map('<A-s-c-q>', 'BufferClose!')                 -- Force close

map('<A-p>', 'BufferPin')                        -- Pin or unpin the current buffer
map('<A-x>', 'BufferCloseAllButCurrentOrPinned') -- Close all but the current and pinned
map('<A-b>', 'BufferPick')                       -- Jump by label

-- Jump by position
for idx = 1, 9 do
    map('<A-' .. idx .. '>', 'BufferGoto ' .. idx .. '')
end
map('<A-0>', 'BufferLast')
