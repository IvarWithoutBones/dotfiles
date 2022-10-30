require 'nvim-treesitter.configs'.setup {
    indent = {
        enable = true,
    },

    highlight = {
        enable = true,

        -- Disable highlighting if the file is larger than 1MB, that can cause slowdowns
        disable = function(_, buf)
            local max_filesize = 1000 * 1024
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,
    },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<C-x>",
            scope_incremental = "<C-j>",
            node_incremental = "<C-l>",
            node_decremental = "<C-h>",
        },
    },
}
