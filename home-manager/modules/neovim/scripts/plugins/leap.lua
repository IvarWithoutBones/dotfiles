require 'leap'.add_default_mappings()

-- Disable keys that are less quick to type for me
require 'leap'.opts = {
    safe_labels = { "s", "f", "n", "u", "t", "m" },
    labels = {
        "s", "f", "n", "j", "k", "l", "h", "o", "d",
        "w", "e", "m", "b", "u", "y", "v", "r", "g",
        "t", "c", "x", "z"
    }
}

-- Fade the background while doing a motion, this makes it easier to see the labels
vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
