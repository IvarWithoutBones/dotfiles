local luasnip = require("luasnip")

-- Register snippets defined in various formats
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()
require("luasnip.loaders.from_lua").lazy_load()

-- Enable snippets for standardized comment formats, from friendly-snippets
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

-- Bindings to jump between placeholders
vim.keymap.set({ "i", "n" }, "<C-h>", function() luasnip.jump(1) end, { silent = true })
vim.keymap.set({ "i", "n" }, "<C-S-h>", function() luasnip.jump(-1) end, { silent = true })
