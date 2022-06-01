{ pkgs, config, ... }:

{
  programs.neovim = {
    enable = true;
    withNodeJs = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      lua
      clang-tools
      ripgrep # For :Telescope live_grep
      xclip # For clipboard support
    ];

    plugins = with pkgs.vimPlugins; [
      plenary-nvim # Dependency of telescope
      vim-nix
      editorconfig-nvim
      nvim-web-devicons

      # Using the latest revision as of 2022-05-14 as previous versions now fail to start:
      # Unhandled status from server: Please upgrade your Copilot extension to continue using this service.
      (copilot-vim.overrideAttrs (attrs: {
        version = "unstable-2022-05-09";

        src = pkgs.fetchFromGitHub {
          owner = "github";
          repo = "copilot.vim";
          rev = "df203c1356b72032df32d7b0b5facb4895139b6e";
          sha256 = "18v21b314p4firiz0xhqnfl45g5wbcigiqq4ypnhf1lgwd6ngpqd";
        };
      }))
      {
        plugin = toggleterm-nvim;
        config = ''
          lua << EOF
            require("toggleterm").setup()
          EOF

          " Pop up terminal config
          nnoremap <silent> <c-o> :ToggleTerm<CR>
          autocmd TermEnter term://*toggleterm#*
            \ tnoremap <silent> <c-o> <Cmd>exe v:count1 . "ToggleTerm"<CR>
        '';
      }
      {
        # Fuzzy file search/grep
        plugin = telescope-nvim;
        config = ''
          nnoremap <silent> tg :Telescope live_grep theme=ivy<CR>
          nnoremap <silent> tk :Telescope find_files theme=ivy<CR>
        '';
      }
      {
        # Theme and related options
        plugin = catppuccin-nvim;
        config = ''
          lua << EOF
            vim.g.catppuccin_flavour = "mocha" -- latte, frappe, macchiato, mocha
            require('catppuccin').setup {
              styles = {
                functions = "italic",
                keywords = "italic",
                variables = "italic",
              },
            }
          EOF

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
        # Automatically changes pwd to git trees root
        plugin = vim-rooter;
        config = ''
          let g:rooter_patterns = ['.git', '=${config.home.homeDirectory}/nix/nixpkgs' ]
        '';
      }
      {
        # Better syntax highlighting and indentation
        plugin = with pkgs.tree-sitter-grammars; (nvim-treesitter.withPlugins (plugins: [
          tree-sitter-bash
          tree-sitter-python
          tree-sitter-nix
          tree-sitter-cmake
          tree-sitter-cpp
          tree-sitter-c
        ]));

        config = ''
          lua << EOF
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
          EOF
        '';
      }
      {
        # Buffer management with nice looking tabs
        plugin = barbar-nvim;
        config = ''
          let bufferline = get(g:, 'bufferline', {})
          let bufferline.animation = v:false

          nnoremap <silent> <s-f> :BufferPick<CR>
          nnoremap <silent> fw :BufferClose<CR>
          nnoremap <silent> fl :BufferNext<CR>
          nnoremap <silent> fh :BufferPrevious<CR>
          nnoremap <silent> fml :BufferMoveNext<CR>
          nnoremap <silent> fmh :BufferMovePrevious<CR>
        '';
      }
      {
        # Status line
        plugin = lualine-nvim;
        config = ''
          lua << EOF
            require('lualine').setup {
              options = {
                theme = "catppuccin",
              }
            }
          EOF
        '';
      }
      {
        # Tree-like file manager
        plugin = nvim-tree-lua;
        config = ''
          map <silent> <c-b> :NvimTreeToggle<CR>

          lua << EOF
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
          EOF
        '';
      }
      {
        # Dependency of some plugins
        plugin = sqlite-lua;
        config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'";
      }
    ];

    coc = {
      enable = true;

      # The version in nixpkgs as of 2022-05-30 fails when rebuilding whenever nodejs is enabled
      package = pkgs.vimUtils.buildVimPluginFrom2Nix {
        pname = "coc.nvim";
        version = "2022-05-21";

        src = pkgs.fetchFromGitHub {
          owner = "neoclide";
          repo = "coc.nvim";
          rev = "791c9f673b882768486450e73d8bda10e391401d";
          sha256 = "sha256-MobgwhFQ1Ld7pFknsurSFAsN5v+vGbEFojTAYD/kI9c=";
        };
      };

      settings = {
        client.snippetSupport = true;

        suggest = {
          enablePreview = true;
          noselect = true;
          enablePreselect = false;
        };

        languageserver = {
          nix = {
            command = "${pkgs.rnix-lsp}/bin/rnix-lsp";
            filetypes = [ "nix" ];
            rootPatterns = [
              "flake.lock"
              ".git"
            ];
          };

          clangd = {
            command = "${pkgs.clang-tools}/bin/clangd";
            compilationDatabasePath = "build/compile_commands.json";

            extraArgs = [
              "--background-index"
            ];

            filetypes = [
              "c"
              "cpp"
              "objc"
              "objcpp"
            ];

            rootPatterns = [
              "CMakeLists.txt"
              "build"
              "src"
            ];
          };
        };
      };
    };

    extraConfig = ''
      syntax enable
      set number
      set relativenumber
      set tabstop=2
      set mouse=a
      set updatetime=300
      set clipboard+=unnamedplus " For system clipboard support, needs xclip
      set signcolumn=number
      set noshowmode

      " use `ALT+{h,j,k,l}` to navigate windows from any mode
      tnoremap <A-h> <C-\><C-N><C-w>h
      tnoremap <A-j> <C-\><C-N><C-w>j
      tnoremap <A-k> <C-\><C-N><C-w>k
      tnoremap <A-l> <C-\><C-N><C-w>l
      inoremap <A-h> <C-\><C-N><C-w>h
      inoremap <A-j> <C-\><C-N><C-w>j
      inoremap <A-k> <C-\><C-N><C-w>k
      inoremap <A-l> <C-\><C-N><C-w>l
      nnoremap <A-h> <C-w>h
      nnoremap <A-j> <C-w>j
      nnoremap <A-k> <C-w>k
      nnoremap <A-l> <C-w>l

      " various fixes for the tab key
      set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
      autocmd FileType nix set tabstop=2 softtabstop=0 shiftwidth=2 expandtab

      " Maps to insert a new line without going into insert mode
      nmap <S-Enter> O<Esc>
      nmap <CR> o<Esc>


      " CoC config. Since i use the home-manager module this cannot be inside of an attrset like the others plugins configuration.
      " Show all diagnostics.
      nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
      " Manage extensions.
      nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
      " Show commands.
      nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
      " Find symbol of current document.
      nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
      " Search workspace symbols.
      nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
      " Do default action for next item.
      nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
      " Do default action for previous item.
      nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
      " Resume latest coc list.
      nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
      " Format the currently open buffer
      nnoremap <silent><nowait> <space>f  :<C-u>CocCommand editor.action.formatDocument<cr>
      " Run the suggested action
      nnoremap <silent><nowait> <space><space>  :<C-u>CocAction<cr>

      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)
      nmap <silent> rn <Plug>(coc-rename)

      inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()

      inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
        \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
  
      inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

      autocmd CursorHold * silent call CocActionAsync('highlight')

      " Use K to show documentation in preview window.
      nnoremap <silent> K :call <SID>show_documentation()<CR>
      inoremap <silent><expr> <c-space> coc#refresh()

      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
      endfunction
  
      function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
          execute 'h '.expand('<cword>')
        elseif (coc#rpc#ready())
          call CocActionAsync('doHover')
        else
          execute '!' . &keywordprg . " " . expand('<cword>')
        endif
      endfunction
    '';
  };
}

