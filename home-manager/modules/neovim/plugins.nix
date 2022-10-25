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

      {
        # Github copilot, requires nodejs-16_x
        plugin = copilot-vim;
        config = ''
          imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
          let g:copilot_no_tab_map = v:true
        '';
      }
      {
        # Label-based code navigation
        plugin = leap-nvim;
        config = mkLua ''
          require('leap').add_default_mappings()
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
        # Fuzzy file search and live grep
        plugin = telescope-nvim;
        config = ''
          nnoremap <silent> tg :Telescope live_grep theme=ivy<CR>
          nnoremap <silent> tk :Telescope find_files theme=ivy<CR>
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
        # Inline git blame
        plugin = git-blame-nvim;
        config = ''
          let g:gitblame_date_format = '%r'
          let g:gitblame_enabled = 0
          nnoremap gb :GitBlameToggle<CR>
        '';
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
          tree-sitter-bash
          tree-sitter-python
          tree-sitter-nix
          tree-sitter-cmake
          tree-sitter-cpp
          tree-sitter-c
        ]));

        config = mkLuaFile ./scripts/plugins/treesitter.lua;
      }
    ];
  };
}
