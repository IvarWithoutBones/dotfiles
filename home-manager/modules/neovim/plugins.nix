{ pkgs
, config
, ...
}:

let
  mkLua = lua: ''
    lua << EOF
      ${lua}
    EOF
  '';
in
{
  programs.neovim = {
    withNodeJs = false; # Provide an older version manually, Github Copilot does not support the latest

    extraPackages = with pkgs; [
      nodejs-16_x # For Github Copilot
      ripgrep # Needed by :Telescope live_grep
      lua
    ];

    plugins = with pkgs.vimPlugins; [
      plenary-nvim # Dependency of telescope
      vim-nix # Nix syntax highlighting
      nvim-web-devicons # Icon support
      editorconfig-nvim

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

        config = mkLua ''
          require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = true,
              disable = {
                'nix'
              },
            },

            indent = {
              enable = true,
            },

            incremental_selection = {
              enable = true,
              keymaps = {
                init_selection = "gn",
                scope_incremental = "gs",
                node_incremental = "gl",
                node_decremental = "gh",
              },
            },
          }
        '';
      }
      {
        # Github copilot
        plugin = copilot-vim;
        config = ''
          imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
          let g:copilot_no_tab_map = v:true
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
        # Pop up terminal
        plugin = toggleterm-nvim;
        config = mkLua ''
          require("toggleterm").setup()
        '' + ''
          nnoremap <silent> <c-o> :ToggleTerm<CR>
          autocmd TermEnter term://*toggleterm#*
            \ tnoremap <silent> <c-o> <Cmd>exe v:count1 . "ToggleTerm"<CR>
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
        # Theme and related options
        plugin = catppuccin-nvim;
        config = mkLua ''
          vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha
          require('catppuccin').setup()
        '' + ''
          set termguicolors
          set cursorline
          colorscheme catppuccin
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
        # Buffer management with nice looking tabs
        plugin = barbar-nvim;
        config = ''
          let bufferline = get(g:, 'bufferline', {})
          let bufferline.animation = v:false

          nnoremap <silent> fw :BufferClose<CR>
          nnoremap <silent> Fw :BufferClose!<CR>
          nnoremap <silent> fl :BufferNext<CR>
          nnoremap <silent> fh :BufferPrevious<CR>
          nnoremap <silent> fml :BufferMoveNext<CR>
          nnoremap <silent> fmh :BufferMovePrevious<CR>
          nnoremap <silent> <s-f> :BufferPick<CR>
        '';
      }
      {
        # Status line
        plugin = lualine-nvim;
        config = mkLua ''
          require('lualine').setup {
            options = {
              theme = "catppuccin"
            }
          }
        '' + ''
          " Dont show 'INSERT', the line already takes care of it
          set noshowmode
        '';
      }
      {
        # Tree-like file manager
        plugin = nvim-tree-lua;
        config = mkLua ''
          require'nvim-tree'.setup {
            update_focused_file = {
              enable = true,
              update_cwd = true,
            },

            filters = {
              dotfiles = false,
            },

            renderer = {
              group_empty = true,
            },

            view = {
              signcolumn = "no",
            },
          }
        '' + ''
          map <silent> <c-b> :NvimTreeToggle<CR>
        '';
      }
      {
        # Dependency of some plugins
        plugin = sqlite-lua;
        config = ''
          let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'
        '';
      }
    ];
  };
}
