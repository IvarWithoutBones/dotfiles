-- Words to ignore when spell checking, note that this can be expanded on a per-project basis:
-- https://github.com/codespell-project/codespell#ignoring-words
local function ignored_words()
    local words = {
        "crate", "tese"
    }

    return table.concat(words, ",")
end

local null_ls = require("null-ls")
null_ls.setup {
    sources = {
        -- Spell checking for code, requires the `codespell` package.
        null_ls.builtins.diagnostics.codespell.with({
            args = {
                "-L", ignored_words(), -- Ignore specified words
                "-"                    -- Read from stdin
            },
        }),

        -- Formatting for shell scripts, requires the `shfmt` package.
        null_ls.builtins.formatting.shfmt.with({
            args = {
                "--binary-next-line",
                "--space-redirects",
                "--case-indent",
                "--simplify",
                "-filename", "$FILENAME" -- Run on the current file
            }
        })
    }
}
