vim.g.rustaceanvim = {
    tools = {
        executor = require('rustaceanvim.executors').toggleterm,
        test_executor = require('rustaceanvim.executors').toggleterm
    },
    server = {
        default_settings = {
            ["rust-analyzer"] = {
                files = {
                    exclude = {
                        -- Ignore all files/directories that contain symlinks to the nix store, as that seemingly causes rust-analyzer to scan the entire store:
                        -- https://github.com/rust-lang/rust-analyzer/issues/14734#issuecomment-2373988391
                        ".direnv",
                        "result",
                        "result-dev",
                        "result-man",
                        "result-out",
                    }
                },

                -- Show diagnostics from `cargo clippy` instead of `cargo check`. The former is a bit stricter.
                check = { command = "clippy" },

                -- Don't show diagnostics for inactive cfg directives.
                diagnostics = { disabled = { "inactive-code" } },
            }
        }
    }
}
