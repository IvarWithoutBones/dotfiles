require 'gitsigns'.setup {
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function binding(key, action, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, key, action, {
                noremap = true, buffer = bufnr
            })
        end

        binding("ml", gs.toggle_current_line_blame)
        binding("ma", gs.stage_hunk)
        binding("mA", gs.stage_buffer)
        binding("mu", gs.undo_stage_hunk)
        binding("mD", gs.diffthis) -- Diff in seperate buffer
        binding("md", function() -- Inline diff
            gs.toggle_deleted()
            gs.toggle_linehl()
        end)
    end
}
