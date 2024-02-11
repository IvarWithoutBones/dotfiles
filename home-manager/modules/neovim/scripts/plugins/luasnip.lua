local ls = require("luasnip")

-- Bindings to jump between placeholders
vim.keymap.set({ "i", "n" }, "<C-h>", function() ls.jump(1) end, { silent = true })
vim.keymap.set({ "i", "n" }, "<C-S-h>", function() ls.jump(-1) end, { silent = true })

-- Enable snippets for standardized comment formats, from friendly-snippets
ls.filetype_extend("rust", { "rustdoc" })
ls.filetype_extend("typescript", { "tsdoc" })
ls.filetype_extend("javascript", { "jsdoc" })
ls.filetype_extend("lua", { "luadoc" })
ls.filetype_extend("python", { "pydoc" })
ls.filetype_extend("rust", { "rustdoc" })
ls.filetype_extend("cs", { "csharpdoc" })
ls.filetype_extend("java", { "javadoc" })
ls.filetype_extend("c", { "cdoc" })
ls.filetype_extend("cpp", { "cppdoc" })
ls.filetype_extend("php", { "phpdoc" })
ls.filetype_extend("kotlin", { "kdoc" })
ls.filetype_extend("ruby", { "rdoc" })
ls.filetype_extend("sh", { "shelldoc" })

-- Custom snippets
ls.add_snippets("sh", {
    ls.parser.parse_snippet("scriptPath", [[${1:SCRIPT_PATH}="$(readlink -f "\$0")"]]),
    ls.parser.parse_snippet("scriptDirectory", [[${1:SCRIPT_DIR}="$(dirname "$(readlink -f "\$0")")"]])
})

ls.add_snippets("json", {
    -- Configure the features used by rust-analyzer, with lspconfig overrides. See `plugins/lspconfig.lua` for details
    ls.parser.parse_snippet("lspconfigRustFeatures", [[
      {
        "rust_analyzer": {
          "settings": {
            "rust-analyzer": {
              "cargo": {
                "features": [
                  "${1}"
                ]
              }
            }
          }
        }
      }
    ]]),
})

-- Register snippets defined in various formats
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load()
require("luasnip.loaders.from_lua").lazy_load()
