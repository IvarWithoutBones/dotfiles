local function contains(table, val)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

-- Get the function currently under the cursor according to treesitter, includes formatting
-- to remove irrelevant information. Also makes sure the text fits in the statusline.
local function getCurrentFunction()
    local disabledFiletypes = { "nix" }
    if contains(disabledFiletypes, vim.bo.filetype) then
        return ""
    end

    local maxLength = (vim.o.columns * 2 / 3) - 15
    local result = ""

    local raw = require 'nvim-treesitter.statusline'.statusline({
        indicator_size = 10000,
        separator = '\n',
    })

    -- Split returned string into a table, last entry is usually the most specific
    local fields = {}
    for value in raw:gmatch("[^\r\n]+") do
        table.insert(fields, value)
    end
    local currentFunction = fields[#fields]

    if currentFunction ~= nil then
        -- Remove function arguments if the function signature is too long
        if string.len(currentFunction) > maxLength then
            local withoutArguments = currentFunction:gsub('%b()', '(...)')
            if withoutArguments ~= nil then
                currentFunction = withoutArguments
            end
        end

        -- Remove class initializers
        local withoutInitializers = currentFunction:gsub(': .+ {}', ': ... {}')
        if withoutInitializers ~= nil then
            currentFunction = withoutInitializers
        end

        -- Remove return type and extra qualifiers
        local withoutType = currentFunction:match('[%a+::]-%a+%p-%(.*%)')
        if withoutType ~= nil then
            currentFunction = withoutType
        end

        result = currentFunction
    end

    if (string.len(result) < maxLength) then
        return result
    else
        return ""
    end
end

require('lualine').setup {
    options = {
        theme = "catppuccin",
        component_separators = '|',
        section_separators = { left = '', right = '' },
        ignore_focus = {
            "NvimTree",
            "toggleterm",
            "TelescopePrompt"
        }
    },

    sections = {
        lualine_a = {
            { 'mode', separator = { left = '' }, right_padding = 2 },
        },
        lualine_b = { "filename", 'diagnostics' },
        lualine_c = { 'branch', 'diff' },
        lualine_x = {},
        lualine_y = { getCurrentFunction, 'progress' },
        lualine_z = {
            { 'filetype', separator = { right = '' }, left_padding = 2 },
        },
    },
}

-- Dont show 'INSERT', the statusline already takes care of it
vim.cmd("set noshowmode")
