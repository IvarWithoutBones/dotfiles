require("catppuccin").setup {
    flavour = "mocha", -- latte, frappe, macchiato, mocha

    integrations = {
        fidget = true,
        leap = true,
    },

    highlight_overrides = {
        mocha = function(colors)
            return {
                -- Colors for barbar, a plugin for managing tabs. This is mostly taken from catppuccin-nvim, but with a few tweaks.
                -- See the original: https://github.com/catppuccin/nvim/blob/919d1f786338ebeced798afbf28cd085cd54542a/lua/catppuccin/groups/integrations/barbar.lua
                BufferCurrent = { bg = colors.crust, fg = colors.text },
                BufferCurrentIndex = { bg = colors.crust, fg = colors.crust },
                BufferCurrentMod = { bg = colors.crust, fg = colors.yellow },
                BufferCurrentSign = { bg = colors.crust, fg = colors.crust },
                BufferCurrentTarget = { bg = colors.crust, fg = colors.red },

                BufferVisible = { bg = colors.mantle, fg = colors.overlay0 },
                BufferVisibleIndex = { bg = colors.mantle, fg = colors.mantle },
                BufferVisibleMod = { bg = colors.mantle, fg = colors.yellow },
                BufferVisibleSign = { bg = colors.mantle, fg = colors.mantle },
                BufferVisibleTarget = { bg = colors.mantle, fg = colors.red },

                BufferInactive = { bg = colors.surface0, fg = colors.overlay0 },
                BufferInactiveIndex = { bg = colors.surface0, fg = colors.surface0 },
                BufferInactiveMod = { bg = colors.surface0, fg = colors.yellow },
                BufferInactiveSign = { bg = colors.surface0, fg = colors.surface0 },
                BufferInactiveTarget = { bg = colors.surface0, fg = colors.red },
            }
        end
    }
}

vim.cmd("colorscheme catppuccin")

-- Override some of the LSP semantic highlighting groups
local mocha = require("catppuccin.palettes").get_palette("mocha")
vim.api.nvim_set_hl(0, "@lsp.type.function", { fg = mocha.sapphire })
vim.api.nvim_set_hl(0, "@lsp.type.enumMember", { fg = mocha.flamingo })
vim.api.nvim_set_hl(0, "@lsp.type.macro", { fg = mocha.teal })

-- Disable special-case highlighting for standard library types, as it looks inconsistent with user-defined symbols.
vim.api.nvim_set_hl(0, "@lsp.typemod.method.defaultLibrary", { link = "@lsp.type.method" })
vim.api.nvim_set_hl(0, "@lsp.typemod.macro.defaultLibrary", { link = "@lsp.type.macro" })
vim.api.nvim_set_hl(0, "@lsp.typemod.function.defaultLibrary", { link = "@lsp.type.function" })
vim.api.nvim_set_hl(0, "@lsp.typemod.class.defaultLibrary", { link = "@lsp.type.class" })
vim.api.nvim_set_hl(0, "@lsp.typemod.enum.defaultLibrary", { link = "@lsp.type.enum" })
vim.api.nvim_set_hl(0, "@lsp.typemod.enumMember.defaultLibrary", { link = "@lsp.type.enumMember" })
vim.api.nvim_set_hl(0, "@lsp.typemod.type.defaultLibrary", { link = "@lsp.type.type" })
vim.api.nvim_set_hl(0, "@lsp.typemod.variable.defaultLibrary", { link = "@lsp.type.variable" })
