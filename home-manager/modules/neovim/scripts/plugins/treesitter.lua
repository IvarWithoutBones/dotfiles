---@diagnostic disable: missing-fields
require("nvim-treesitter.configs").setup {
    auto_install = false, -- Managed by nix

    indent = {
        enable = true,
    },

    highlight = {
        enable = true,

        disable = function(lang, buf)
            -- Disable highlighting if the file is larger than 1MB, as that can cause slowdowns
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            local too_large = ok and stats and (stats.size > (1000 * 1024))
            -- Also disable vimdoc highlighting, it appears to be broken
            return too_large or (lang == "vimdoc")
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
