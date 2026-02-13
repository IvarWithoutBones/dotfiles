-- Dont use treesitter-based auto indentation for languages that have poor support
local disabled_indent_languages = {
    "python",
    "cmake",
}

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('ivar.treesitter.setup', {}),
    callback = function(args)
        -- Ensure we have a treesitter parser for this filetype
        local language = vim.treesitter.language.get_lang(args.match) or args.match
        if not vim.treesitter.language.add(language) then
            return
        end

        -- Enable the builtin treesitter-based syntax highlighting
        vim.treesitter.start(args.buf, language)

        -- Enable the builtin treesitter-based code folding
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo.foldmethod = 'expr'

        -- Enable automatic indentation from treesitter, unless disabled for this language
        if not vim.tbl_contains(disabled_indent_languages, language) then
            vim.bo[args.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
        end
    end,
})

-- Use the `treesitter-modules` plugin for incremental selection
require("treesitter-modules").setup({
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<C-j>",
            scope_incremental = "<C-j>",
            node_incremental = "<C-l>",
            node_decremental = "<C-h>",
        },
    }
})

-- Better navigation around textobjects, using the `nvim-treesitter-textobjects` plugin
require("nvim-treesitter-textobjects").setup({
    move = {
        set_jumps = true, -- Update the jumplist
    },

    select = {
        lookahead = true, -- Automatically jump forward to the next textobject
        include_surrounding_whitespace = true,
    },
})

local function binding(key, action, desc, mode)
    vim.keymap.set(mode or "n", key, action, { noremap = true, desc = desc })
end

-- Swapping
binding("<space>r", function()
    require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
end, "Swap next parameter (inner)")

binding("<space>R", function()
    require("nvim-treesitter-textobjects.swap").swap_next("@parameter.outer")
end, "Swap next parameter (outer)")

-- Selection
binding("af", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end, "Select around function", { "o", "x" })

binding("if", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end, "Select inside function", { "o", "x" })

binding("ac", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
end, "Select around class", { "o", "x" })

binding("ic", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
end, "Select inside class", { "o", "x" })

-- Movement
local function move_binding(key, action, desc)
    local new_action = function()
        return action(require("nvim-treesitter-textobjects.move"))
    end
    binding(key, new_action, desc, { "n", "x", "o" })
end

move_binding("]a", function(x) x.goto_next_start("@parameter.inner", "textobjects") end, "Go to next parameter start")
move_binding("]q", function(x) x.goto_next_start("@function.outer", "textobjects") end, "Go to next function start")
move_binding("]]", function(x) x.goto_next_start("@class.outer", "textobjects") end, "Go to next class start")

move_binding("]A", function(x) x.goto_next_end("@parameter.inner", "textobjects") end, "Go to next parameter end")
move_binding("]Q", function(x) x.goto_next_end("@function.outer", "textobjects") end, "Go to next function end")
move_binding("][", function(x) x.goto_next_end("@class.outer", "textobjects") end, "Go to next class end")

move_binding("[a", function(x) x.goto_previous_start("@parameter.inner", "textobjects") end,
    "Go to previous parameter start")
move_binding("[q", function(x) x.goto_previous_start("@function.outer", "textobjects") end,
    "Go to previous function start")
move_binding("[[", function(x) x.goto_previous_start("@class.outer", "textobjects") end, "Go to previous class start")

move_binding("[A", function(x) x.goto_previous_end("@parameter.inner", "textobjects") end, "Go to previous parameter end")
move_binding("[Q", function(x) x.goto_previous_end("@function.outer", "textobjects") end, "Go to previous function end")
move_binding("[]", function(x) x.goto_previous_end("@class.outer", "textobjects") end, "Go to previous class end")

-- Disable some reStructuredText highlighting which gets incorrectly applied for Python docstrings.
-- A better solution would be to fix the injection query: the contents indentation gets misinterpreted.
vim.api.nvim_set_hl(0, "@markup.strong.rst", { link = "@spell.rst" })
vim.api.nvim_set_hl(0, "@markup.quote.rst", { link = "@spell.rst" })
