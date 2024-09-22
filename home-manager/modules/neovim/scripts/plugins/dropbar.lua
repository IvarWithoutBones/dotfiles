local function set_highlight_take_foreground(opts, source_hl, target_hl)
    if target_hl == nil then target_hl = source_hl end
    local fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(source_hl)), "fg#")
    if fg == "" then
        vim.api.nvim_set_hl(0, target_hl, opts)
    else
        vim.api.nvim_set_hl(0, target_hl, vim.tbl_extend("force", opts, { fg = fg }))
    end
end


-- Modified version of https://github.com/Bekaboo/dropbar.nvim/issues/2#issuecomment-1568244312, thanks!
local function bar_background_color_source()
    local function color_symbols(symbols, opts)
        for _, symbol in ipairs(symbols) do
            local source_hl = symbol.icon_hl
            symbol.icon_hl = "DropbarSymbol" .. symbol.icon_hl
            symbol.name_hl = symbol.icon_hl
            set_highlight_take_foreground(opts, source_hl, symbol.icon_hl)
        end
        return symbols
    end

    return {
        get_symbols = function(buf, win, cursor)
            -- Use the background of the WinBar highlight group
            local opts = { bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("WinBar")), "bg#") }
            local sources = require('dropbar.sources')
            if vim.bo[buf].ft == "markdown" then
                return color_symbols(sources.markdown.get_symbols(buf, win, cursor), opts)
            end
            if vim.bo[buf].ft == "terminal" then
                return color_symbols(sources.terminal.get_symbols(buf, win, cursor), opts)
            end

            for _, source in ipairs({ sources.lsp, sources.treesitter }) do
                local symbols = source.get_symbols(buf, win, cursor)
                if not vim.tbl_isempty(symbols) then
                    return color_symbols(symbols, opts)
                end
            end
            return {}
        end
    }
end

-- TODO: This should be configured from the colorscheme. The reason we use an autocmd here is because the colorscheme overrides the WinBar highlight group.
vim.api.nvim_create_autocmd('BufWinEnter', {
    pattern = { '*' },
    callback = function()
        local opts = { bg = "#181825" }
        vim.api.nvim_set_hl(0, "WinBar", opts)
        set_highlight_take_foreground(opts, "DropBarIconUISeparator")
        set_highlight_take_foreground(opts, "DropBarIconUIPickPivot")
    end,
})

vim.keymap.set({ "n", "i" }, "<C-c>", function() require('dropbar.api').pick() end, {
    noremap = true,
    nowait = true,
    desc = "Open dropbar interactive picker",
})

require("dropbar").setup({
    bar = {
        sources = function(_, _)
            return { bar_background_color_source() }
        end
    },

    menu = {
        preview = false, -- Dont automatically jump to the item under the cursor
        win_configs = {
            border = "rounded",
        },
    },
})
