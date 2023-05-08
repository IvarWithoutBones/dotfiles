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
      nodejs-16_x # For Github Copilot
      ripgrep # Needed by :Telescope live_grep
    ];

    extraPlugins = with pkgs.vimPlugins; [
      plenary-nvim # Dependency of telescope
      vim-nix # Nix syntax highlighting
      nvim-web-devicons # Icon support
      editorconfig-nvim # Editorconfig support
      dressing-nvim # Better defaults for the basic UI
      vim-just # Syntax highlighting for justfiles, package from my overlay

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
        # Github copilot, requires nodejs-16_x
        plugin = copilot-vim;
        config = ''
          imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
          let g:copilot_no_tab_map = v:true
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
      {
        # Information about Rust dependencies inside of Cargo.toml
        plugin = crates-nvim;
        config = mkLuaFile ./scripts/plugins/crates-nvim.lua;
      }
      {
        # Formatting for languages without LSP formatting support
        plugin = formatter-nvim;
        config = mkLuaFile (pkgs.substituteAll {
          src = ./scripts/plugins/formatter-nvim.lua;
          shfmt = "${pkgs.shfmt}/bin/shfmt";
        });
      }

      # Extra plugins for treesitter
      playground
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
          # From my overlay
          tree-sitter-astro
        ]);

        config = mkLuaFile ./scripts/plugins/treesitter.lua;
      }
    ];
  };
}
