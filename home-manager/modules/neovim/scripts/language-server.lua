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

-- Set up snippets using luasnip
local luasnip = require("luasnip")
vim.keymap.set({ "i", "n" }, "<C-h>", function() luasnip.jump(1) end, { silent = true })
vim.keymap.set({ "i", "n" }, "<C-S-h>", function() luasnip.jump(-1) end, { silent = true })

-- Register snippets defined in various formats
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()
require("luasnip.loaders.from_lua").lazy_load()

-- Enable snippets for standardized comments from friendly-snippets
luasnip.filetype_extend("rust", { "rustdoc" })
luasnip.filetype_extend("typescript", { "tsdoc" })
luasnip.filetype_extend("javascript", { "jsdoc" })
luasnip.filetype_extend("lua", { "luadoc" })
luasnip.filetype_extend("python", { "pydoc" })
luasnip.filetype_extend("rust", { "rustdoc" })
luasnip.filetype_extend("cs", { "csharpdoc" })
luasnip.filetype_extend("java", { "javadoc" })
luasnip.filetype_extend("c", { "cdoc" })
luasnip.filetype_extend("cpp", { "cppdoc" })
luasnip.filetype_extend("php", { "phpdoc" })
luasnip.filetype_extend("kotlin", { "kdoc" })
luasnip.filetype_extend("ruby", { "rdoc" })
luasnip.filetype_extend("sh", { "shelldoc" })

-- The completion engine, nvim-cmp
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
                buffer = "[Buf]",
                nvim_lsp = "[LSP]",
                luasnip = "[Snip]",
                path = "[Path]",
            }),

            -- Disable possible text after the source name, e.g. function signatures
            before = function(_, item)
                item.menu = ""
                return item
            end
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

-- Configure defaults for all language servers using lspconfig
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
