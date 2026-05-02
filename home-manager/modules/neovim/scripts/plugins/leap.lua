-- Disable highlight of current context by indent-blankline when beginning a motion
vim.api.nvim_create_autocmd("User", {
    pattern = "LeapEnter",
    callback = function() vim.cmd("IBLDisable") end,
})
vim.api.nvim_create_autocmd("User", {
    pattern = "LeapLeave",
    callback = function() vim.cmd("IBLEnable") end,
})

local function binding(key, action, mode)
    mode = mode or "n"
    vim.keymap.set(mode, key, action, {
        noremap = true,
        silent = true,
    })
end

-- Bidirectional and cross-split search
local function searchAnywhere()
    require("leap").leap({
        target_windows = vim.tbl_filter(
            function(win) return vim.api.nvim_win_get_config(win).focusable end,
            vim.api.nvim_tabpage_list_wins(0)
        ),
    })

    -- For some reason insert mode is entered after the search sometimes
    vim.cmd("stopinsert")
end

binding("s", function() searchAnywhere() end)
binding("s", function() searchAnywhere() end, "v")

-- Use leap for f/t motions. Copied from the documentation: https://github.com/ggandor/leap.nvim/blob/f5fe479e20d809df7b54ad53142c2bdb0624c62a/README.md?plain=1#L700
do
    -- Returns an argument table for `leap()`, tailored for f/t-motions.
    local function as_ft(key_specific_args)
        local common_args = {
            inputlen = 1,
            inclusive = true,
            opts = {
                labels = "", -- force autojump
                safe_labels = vim.fn.mode(1):match("o") and "" or nil,
            },
        }
        return vim.tbl_deep_extend("keep", common_args, key_specific_args)
    end

    local clever = require("leap.user").with_traversal_keys
    local clever_f = clever("f", "F")
    local clever_t = clever("t", "T")

    for key, args in pairs({
        f = { opts = clever_f },
        F = { backward = true, opts = clever_f },
        t = { offset = -1, opts = clever_t },
        T = { backward = true, offset = 1, opts = clever_t },
    }) do
        vim.keymap.set({ "n", "x", "o" }, key, function() require("leap").leap(as_ft(args)) end)
    end
end
