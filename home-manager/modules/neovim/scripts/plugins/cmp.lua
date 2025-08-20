local cmp_buffer = require("cmp_buffer")
local cmp = require("cmp")

cmp.setup {
    sources = {
        { name = "nvim_lsp", priority = 10 },
        { name = "path",     priority = 9 },
        { name = "luasnip",  priority = 5 },
        {
            name = "buffer",
            priority = 1,
            option = {
                -- Complete from all open buffers, not only the one that is currently active
                get_bufnrs = function() return vim.api.nvim_list_bufs() end
            }
        },
    },

    sorting = {
        comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            -- Sort buffer completion items by distance from the cursor
            function(...) return cmp_buffer:compare_locality(...) end,
            cmp.config.compare.kind,
        }
    },

    snippet = {
        -- Expand snippets using luasnip, see `plugins/luasnip.lua`
        expand = function(args) require("luasnip").lsp_expand(args.body) end,
    },

    mapping = cmp.mapping.preset.insert({
        ['<cr>'] = cmp.mapping.confirm({ select = false }), -- Insert selected completion
        ['<C-d>'] = cmp.mapping.scroll_docs(4),             -- Scroll backwards through documentation
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),            -- Scroll forwards through documentation

        -- Toggle the completion menu
        ['<C-c>'] = cmp.mapping(function()
            if cmp.visible() then
                cmp.abort()
            else
                cmp.complete()
            end
        end, { "i", "s" }),

        -- Cycle through completion items
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { "i", "s" }),

        -- Cycle backwards through completion items
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { "i", "s" }),
    }),

    window = {
        -- Use rounded borders
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },

    formatting = {
        -- Include icons in completion menu
        format = require("lspkind").cmp_format({
            mode = "symbol_text",
            menu = ({
                buffer = "[Buf]",
                nvim_lsp = "[LSP]",
                luasnip = "[Snip]",
                path = "[Path]",
            }),
        })
    },
}

-- Autocomplete git/github/gitlab issues, pull requests, usernames, and commits
require("cmp_git").setup()
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'git' },
        { name = 'buffer' },
    })
})

-- Use the cmp completion menu for searching through the current buffer
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    view = {
        -- Show a vertical completion menu
        entries = { name = 'wildmenu', separator = '|' }
    },
    sources = {
        { name = 'buffer' }
    }
})

-- Use the cmp completion menu when entering vim commands
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    view = {
        -- Show a vertical completion menu
        entries = { name = 'wildmenu', separator = '|' }
    },
    sources = cmp.config.sources({
        { name = 'path' },
        { name = 'cmdline' }
    })
})
