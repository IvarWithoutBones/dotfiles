-- Always show the signcolumn, otherwise text would be shifted upon errors
vim.opt.signcolumn = "yes"

-- Replace existing signs for diagnostics with our icons
local signs = {
    Error = "",
    Warn = "",
    Hint = "",
    Info = ""
}

for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Rounded corners for popup boxes
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = 'rounded'
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- luasnip setup
local luasnip = require("luasnip")
vim.keymap.set({ "i", "n" }, "<C-h>", function() luasnip.jump(1) end, { silent = true })

-- nvim-cmp setup
local cmp = require("cmp")
cmp.setup {
    sources = {
        { name = "nvim_lsp",   priority = 10 },
        { name = "path",       priority = 9 },
        { name = "luasnip",    priority = 5 },
        { name = "buffer",     priority = 1, keyword_length = 2 },
        { name = "dictionary", priority = 1, keyword_length = 2 },
    },

    snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
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
        end),

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
                buffer = "[Buffer]",
                nvim_lsp = "[LSP]",
                luasnip = "[LuaSnip]",
                path = "[Path]",
                dictionary = "[Dict]",
            })
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

-- Completion from a dictionary
local dict = require("cmp_dictionary")
dict.setup({
    max_items = 5,
})
dict.switcher({
    spelllang = {
        -- Will get substituted to a path containing the required file
        en = "@englishDictionary@",
    },
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

-- lspconfig setup
local on_lsp_attach = function(_, buffer)
    local function binding(key, action, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, key, action, {
            buffer = buffer,
            noremap = true,
            nowait = true,
        })
    end

    -- Format the current buffer
    binding('<space>f', function()
        vim.lsp.buf.format({ async = true })
    end)

    -- Show information about function signature
    binding('<C-k>', vim.lsp.buf.signature_help)
    binding('<C-k>', vim.lsp.buf.signature_help, 'i')

    binding('K', vim.lsp.buf.hover)                    -- Show hover information
    binding('rn', vim.lsp.buf.rename)                  -- Rename symbol
    binding('<space><space>', vim.lsp.buf.code_action) -- Code actions
end

-- languageServers is substituted from the nix expression that imports this file.
loadstring([[languageServers = { @languageServers@ }]])()
local defaultOptions = {
    on_attach = on_lsp_attach,
    capabilities = require("cmp_nvim_lsp").default_capabilities()
}

---@diagnostic disable-next-line: undefined-global
for name, options in pairs(languageServers) do
    local mergedOptions = vim.tbl_deep_extend("force", defaultOptions, options)
    require("lspconfig")[name].setup(mergedOptions)
end
