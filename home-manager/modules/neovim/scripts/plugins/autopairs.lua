local pairs = require "nvim-autopairs"
local Rule = require 'nvim-autopairs.rule'
pairs.setup {}

-- Multiline quotes ('') for nix
pairs.get_rule("'")[1].not_filetypes = { "nix" }
pairs.add_rules {
    Rule(".*''$", "''", { "nix" })
        :use_regex(true),
}

-- Automatically close arrows
pairs.add_rules {
    Rule(".*<$", ">")
        :use_regex(true),
}
