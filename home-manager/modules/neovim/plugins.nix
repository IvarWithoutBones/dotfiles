{ pkgs
, dotfiles-flake
, ...
}:

let
  inherit (dotfiles-flake.lib.vim) mkLua mkLuaFile;
in
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      ripgrep # For telescope's `live_grep`

      # Packages used by `none-ls-nvim`
      codespell # Spell checking
      shfmt # Shell script formatting
    ];

    extraPlugins = with pkgs.vimPlugins; [
      plenary-nvim # Dependency of telescope
      nvim-web-devicons # Icon support
      editorconfig-nvim # Editorconfig support
      dressing-nvim # Better defaults for the basic UI
      vim-just # Justfile syntax highlighting
      vim-gas # Better syntax highlighting for GNU assembly

      {
        plugin = codeium-vim;
        config = mkLua ''
          -- Use the language server binary from nixpkgs, instead of downloading a binary at runtime.
          -- This is required on NixOS, as we cannot `patchelf` the binary the plugin would download.
          vim.g.codeium_bin = "${pkgs.codeium}/bin/codeium_language_server"

          -- Accept completions using control+j instead of tab
          vim.g.codeium_no_map_tab = 1
          vim.keymap.set('i', '<C-j>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
        '';
      }
      {
        # Dependency of telescope
        plugin = sqlite-lua;
        config = ''
          let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'
        '';
      }
      {
        # Automatically insert a comment with a keybinding
        plugin = comment-nvim;
        config = mkLua ''
          require('Comment').setup()
        '';
      }
      {
        # Display LSP progress messages
        plugin = fidget-nvim;
        config = mkLua ''
          require("fidget").setup()
        '';
      }
      {
        # Enhanced f/t motions using Leap
        plugin = flit-nvim;
        config = mkLua ''
          require("flit").setup()
        '';
      }
      {
        # Easily modify surrounding delimiter pairs
        plugin = nvim-surround;
        config = mkLua ''
          require("nvim-surround").setup()
        '';
      }
      {
        # Information about the signature at the current cursor position, used by lualine
        plugin = lsp_signature-nvim;
        config = mkLua ''
          require("lsp_signature").setup({
            -- Dont show signature help in a floating window or hint text, lualine will do so instead
            floating_window = false,
            hint_enable = false,
            always_trigger = true,
          })
        '';
      }
      {
        # Status line
        plugin = lualine-nvim;
        config = mkLuaFile ./scripts/plugins/lualine.lua;
      }
      {
        # Injects LSP diagnostics, code actions, etc for packages without a language server.
        # Configuration requires the `codespell`, `jq` and `shfmt` packages. Dependency of `crates-nvim`.
        plugin = none-ls-nvim;
        config = mkLuaFile ./scripts/plugins/none-ls.lua;
      }
      {
        # Information about Rust dependencies inside of Cargo.toml.
        # Requires the `none-ls-nvim` and `cmp-nvim` plugins.
        plugin = crates-nvim;
        config = mkLuaFile ./scripts/plugins/crates-nvim.lua;
      }
      {
        # Label-based code navigation
        plugin = leap-nvim;
        config = mkLuaFile ./scripts/plugins/leap.lua;
      }
      {
        # Display possible keybindings as you type
        plugin = which-key-nvim;
        config = mkLuaFile ./scripts/plugins/which-key.lua;
      }
      {
        # Fuzzy finder for files, buffers, git branches, etc
        plugin = telescope-nvim;
        config = mkLuaFile ./scripts/plugins/telescope.lua;
      }
      {
        # Show git information in signcolumn
        plugin = gitsigns-nvim;
        config = mkLuaFile ./scripts/plugins/gitsigns.lua;
      }
      {
        # Show indentation guides
        plugin = indent-blankline-nvim;
        config = mkLuaFile ./scripts/plugins/indent-blankline.lua;
      }
      {
        # Interactive diagnostics and tree-based symbol navigation
        plugin = trouble-nvim;
        config = mkLuaFile ./scripts/plugins/trouble.lua;
      }
      {
        # Automatically insert braces, brackets, etc
        plugin = nvim-autopairs;
        config = mkLuaFile ./scripts/plugins/autopairs.lua;
      }
      {
        # Pop up terminal
        plugin = toggleterm-nvim;
        config = mkLuaFile ./scripts/plugins/toggleterm.lua;
      }
      {
        # Theme
        plugin = catppuccin-nvim;
        config = mkLuaFile ./scripts/plugins/catppuccin.lua;
      }
      {
        # Buffer management with nice looking tabs
        plugin = barbar-nvim;
        config = mkLuaFile ./scripts/plugins/barbar.lua;
      }
      {
        # Tree-like file manager
        plugin = nvim-tree-lua;
        config = mkLuaFile ./scripts/plugins/nvim-tree.lua;
      }

      telescope-fzf-native-nvim # Dependency of dropbar-nvim
      {
        # Show context such as the function the cursor is in inside of the winbar
        plugin = dropbar-nvim;
        config = mkLuaFile ./scripts/plugins/dropbar.lua;
      }

      # UI addons for nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      telescope-dap-nvim
      {
        # Debug Adapter Protocol integration for debugging
        plugin = nvim-dap;
        config = mkLuaFile ./scripts/plugins/dap.lua;
      }

      rustaceanvim # Used in ./scripts/plugins/lspconfig.lua
      {
        # Language server configuration presets
        plugin = nvim-lspconfig;
        config = mkLuaFile ./scripts/plugins/lspconfig.lua;
      }

      # Sources for nvim-cmp
      cmp-nvim-lsp
      cmp-path
      cmp-buffer
      cmp-cmdline
      cmp-git
      cmp_luasnip
      lspkind-nvim
      {
        # Completion engine
        plugin = nvim-cmp;
        config = mkLuaFile ./scripts/plugins/cmp.lua;
      }

      friendly-snippets # Collection of snippets for luasnip
      {
        # Snippet support
        plugin = luasnip;
        config = mkLuaFile ./scripts/plugins/luasnip.lua;
      }

      nvim-treesitter-textobjects # For treesitter
      {
        # Better syntax highlighting and automatic indentation
        plugin = nvim-treesitter.withPlugins (plugins: with plugins; [
          tree-sitter-json
          tree-sitter-json5
          tree-sitter-toml
          tree-sitter-yaml
          tree-sitter-rust
          tree-sitter-python
          tree-sitter-nix
          tree-sitter-cmake
          tree-sitter-make
          tree-sitter-cpp
          tree-sitter-c
          tree-sitter-c-sharp
          tree-sitter-bash
          tree-sitter-lua
          tree-sitter-css
          tree-sitter-scss
          tree-sitter-typescript
          tree-sitter-javascript
          tree-sitter-tsx
          tree-sitter-html
          tree-sitter-http
          tree-sitter-markdown
          tree-sitter-markdown-inline
          tree-sitter-regex
          tree-sitter-vim
          tree-sitter-query
          tree-sitter-llvm
          tree-sitter-go
          tree-sitter-zig
          tree-sitter-sql
          tree-sitter-wgsl
          tree-sitter-glsl
          tree-sitter-cuda
          tree-sitter-perl
          tree-sitter-ruby
          tree-sitter-latex
          tree-sitter-proto
          tree-sitter-devicetree
          tree-sitter-dockerfile
          # From my overlay
          tree-sitter-astro
        ]);

        config = mkLuaFile ./scripts/plugins/treesitter.lua;
      }
    ];
  };
}
