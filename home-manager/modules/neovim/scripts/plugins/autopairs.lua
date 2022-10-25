local pairs = require "nvim-autopairs"
local Rule = require 'nvim-autopairs.rule'
pairs.setup {}

-- Multiline quotes ('') for nix
pairs.get_rule("'")[1].not_filetypes = { "nix" }
pairs.add_rules {
    -- On "foo = ''"
    Rule(".*=%s*''$", "''", { "nix" })
        :use_regex(true),

    -- On "} ''"
    Rule(".*}%s*''$", "''", { "nix" })
        :use_regex(true)
}
