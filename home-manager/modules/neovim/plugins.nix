{ pkgs
, config
, dotfiles-lib
, ...
}:

let
  inherit (dotfiles-lib.vim) mkLua mkLuaFile;
in
{
  programs.neovim = {
    withNodeJs = false; # Provide an older version manually, Github Copilot does not support the latest

    extraPackages = with pkgs; [
      nodejs-16_x # For Github Copilot
      ripgrep # Needed by :Telescope live_grep
    ];

    plugins = with pkgs.vimPlugins; [
      plenary-nvim # Dependency of telescope
      vim-nix # Nix syntax highlighting
      nvim-web-devicons # Icon support
      editorconfig-nvim # Editorconfig support
      playground # Show AST using treesitter
      dressing-nvim # Better defaults for the basic UI

      {
        # Github copilot, requires nodejs-16_x
        plugin = copilot-vim;
        config = ''
          imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
          let g:copilot_no_tab_map = v:true
        '';
      }
      {
        # Compiler integration that shows you the generated assembly
        plugin = compiler-explorer-nvim;
        config = mkLuaFile ./scripts/plugins/compiler-explorer.lua;
      }
      {
        # Automatically insert a comment with a keybinding
        plugin = comment-nvim;
        config = mkLua ''
          require('Comment').setup()
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
        # Label-based code navigation
        plugin = leap-nvim;
        config = mkLuaFile ./scripts/plugins/leap.lua;
      }
      {
        # Interactive code actions
        plugin = nvim-code-action-menu;
        config = mkLuaFile ./scripts/plugins/code-action-menu.lua;
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
        # Better syntax highlighting and automatic indentation
        plugin = with pkgs.tree-sitter-grammars; (nvim-treesitter.withPlugins (plugins: [
          tree-sitter-json
          # tree-sitter-rust
          tree-sitter-python
          tree-sitter-nix
          tree-sitter-cmake
          tree-sitter-cpp
          tree-sitter-c
          tree-sitter-lua
        ]));

        config = mkLuaFile ./scripts/plugins/treesitter.lua;
      }
    ];
  };
}
