{ pkgs
, dotfiles-lib
, ...
}:

let
  inherit (dotfiles-lib.vim) mkLua mkLuaFile;
in
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      nodejs # For Github Copilot
      ripgrep # For telescope's `live_grep`

      # Packages used by `null-ls-nvim`
      codespell # Spell checking
      shfmt # Shell script formatting
    ];

    extraPlugins = with pkgs.vimPlugins; [
      plenary-nvim # Dependency of telescope
      nvim-web-devicons # Icon support
      editorconfig-nvim # Editorconfig support
      dressing-nvim # Better defaults for the basic UI
      vim-nix # Nix syntax highlighting
      vim-llvm # LLVM IR syntax highlighting
      vim-just # Justfile syntax highlighting, package from my overlay

      {
        # Better syntax highlighting for GNU assembly, package from my overlay
        plugin = vim-gas;
        config = mkLua ''
          -- Set the filetype by default for assembly
          vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
            pattern = {"*.s", "*.S", "*.as", "*.AS", "*.asm", "*.ASM"},
            command = "set filetype=gas"
          })
        '';
      }
      {
        # Github copilot, requires nodejs
        plugin = copilot-vim;
        config = ''
          " Accept suggestions using ctrl-j instead of tab
          let g:copilot_no_tab_map = v:true
          imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
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
          require("fidget").setup {
            notification = {
              window = {
              -- Required for catpuccin
                winblend = 0,
              },
            }
          }
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
        # Injects LSP diagnostics, code actions, etc for packages without a language server.
        # Configuration requires the `codespell` and `shfmt` packages. Dependency of `crates-nvim`.
        plugin = null-ls-nvim;
        config = mkLuaFile ./scripts/plugins/null-ls.lua;
      }
      {
        # Information about Rust dependencies inside of Cargo.toml.
        # Requires the `null-ls-nvim` and `coq_nvim` plugins.
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
        # Interactive diagnostics
        plugin = trouble-nvim;
        config = mkLuaFile ./scripts/plugins/trouble.lua;
      }
      {
        # Tree-based symbol viewer
        plugin = symbols-outline-nvim;
        config = mkLuaFile ./scripts/plugins/symbols-outline.lua;
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
        # Status line
        plugin = lualine-nvim;
        config = mkLuaFile ./scripts/plugins/lualine.lua;
      }
      {
        # Tree-like file manager
        plugin = nvim-tree-lua;
        config = mkLuaFile ./scripts/plugins/nvim-tree.lua;
      }

      # Extra plugins for treesitter
      nvim-treesitter-textobjects
      {
        # Better syntax highlighting and automatic indentation
        plugin = nvim-treesitter.withPlugins (plugins: with plugins; [
          tree-sitter-json
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
          tree-sitter-typescript
          tree-sitter-javascript
          tree-sitter-tsx
          tree-sitter-html
          tree-sitter-markdown
          tree-sitter-markdown-inline
          tree-sitter-regex
          tree-sitter-vim
          tree-sitter-llvm
          # From my overlay
          tree-sitter-astro
        ]);

        config = mkLuaFile ./scripts/plugins/treesitter.lua;
      }
    ];
  };
}
