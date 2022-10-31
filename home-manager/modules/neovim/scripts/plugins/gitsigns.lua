require 'gitsigns'.setup {
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function binding(key, action, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, key, action, {
                noremap = true, buffer = bufnr
            })
        end

        binding("gb", gs.toggle_current_line_blame)
        binding("gd", gs.diffthis)
        binding("gD", gs.toggle_word_diff)
        binding("gr", gs.toggle_deleted)
    end
}
