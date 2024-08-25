-- Words to ignore when spell checking, note that this can be expanded on a per-project basis:
-- https://github.com/codespell-project/codespell#ignoring-words
local function ignored_words()
    local words = { "crate", "tese" }
    return table.concat(words, ",")
end

local null_ls = require("null-ls")
null_ls.setup {
    sources = {
        null_ls.builtins.formatting.jq, -- JSON formatting, requires the `jq` package

        -- Shell script formatting, requires the `shfmt` package.
        null_ls.builtins.formatting.shfmt.with({
            args = {
                "--binary-next-line",
                "--space-redirects",
                "--case-indent",
                "--simplify",
                "--case-indent",
                "--apply-ignore",
                "-filename", "$FILENAME" -- Run on the current file
            }
        }),

        -- Spell checking for code, requires the `codespell` package.
        null_ls.builtins.diagnostics.codespell.with({
            args = {
                "-L", ignored_words(), -- Ignore specified words
                "-"                    -- Read from stdin
            },
        }),
    }
}
