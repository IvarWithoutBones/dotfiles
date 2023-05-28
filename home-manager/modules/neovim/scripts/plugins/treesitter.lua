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
            init_selection = "<C-j>",
            scope_incremental = "<C-j>",
            node_incremental = "<C-l>",
            node_decremental = "<C-h>",
        },
    },

    -- Better navigation around textobjects, using the `nvim-treesitter-textobjects` plugin
    textobjects = {
        move = {
            enable = true,
            set_jumps = true, -- Update the jumplist

            goto_next_start = {
                ["]a"] = { query = "@parameter.inner", desc = "Go to next parameter start" },
                ["]q"] = { query = "@function.outer", desc = "Go to next function start" },
                ["]]"] = { query = "@class.outer", desc = "Go to next class start" },
            },

            goto_next_end = {
                ["]A"] = { query = "@parameter.inner", desc = "Go to next parameter end" },
                ["]Q"] = { query = "@function.outer", desc = "Go to next function end" },
                ["]["] = { query = "@class.outer", desc = "Go to next class end" },
            },

            goto_previous_start = {
                ["[a"] = { query = "@parameter.inner", desc = "Go to previous parameter start" },
                ["[q"] = { query = "@function.outer", desc = "Go to previous function start" },
                ["[["] = { query = "@class.outer", desc = "Go to previous class start" },
            },

            goto_previous_end = {
                ["[A"] = { query = "@parameter.inner", desc = "Go to previous parameter end" },
                ["[Q"] = { query = "@function.outer", desc = "Go to previous function end" },
                ["[]"] = { query = "@class.outer", desc = "Go to previous class end" },
            },
        },

        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to the next textobject

            keymaps = {
                ["af"] = { query = "@function.outer", desc = "Select outer part of function" },
                ["if"] = { query = "@function.inner", desc = "Select inner part of function" },
                ["ac"] = { query = "@class.outer", desc = "Select outer part of function" },
                ["ic"] = { query = "@class.inner", desc = "Select inner part of class" },
            },
        },

        lsp_interop = {
            enable = true,
            border = 'rounded',

            peek_definition_code = {
                ["<space>p"] = { query = "@function.outer", desc = "Preview function" },
                ["<space>P"] = { query = "@class.outer", desc = "Preview class" },
            },
        },
    },
}
