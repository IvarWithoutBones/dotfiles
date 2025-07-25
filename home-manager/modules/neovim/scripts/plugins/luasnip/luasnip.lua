local ls = require("luasnip")
local function binding(desc, bind, func)
    vim.keymap.set({ "i", "s", "n" }, bind, func, { silent = true, desc = desc })
end

binding("Next placeholder", "<C-h>", function() ls.jump(1) end)
binding("Previous placeholder", "<C-S-h>", function() ls.jump(-1) end)

binding("Choose next option", "<A-h>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end)

binding("Choose previous option", "<A-S-h>", function()
    if ls.choice_active() then
        ls.change_choice(-1)
    end
end)

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

-- Register snippets defined in various formats
require("luasnip.loaders.from_snipmate").lazy_load()
require("luasnip.loaders.from_lua").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load()

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
