{ pkgs, config, ... }:

{
  programs.neovim = {
    enable = true;
  
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  
    plugins = with pkgs.vimPlugins; [
      copilot-vim

      barbar-nvim
      toggleterm-nvim
      coc-nvim
      editorconfig-nvim

      vim-rooter
      vim-nix

      airline
      tender-vim
      telescope-nvim
      plenary-nvim # Dependency of telescope
      {
        plugin = sqlite-lua;
        config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'";
      }
      {
        plugin = nvim-tree-lua;
        config = ''
          map <silent> <c-b> :NvimTreeToggle<CR>

          let g:nvim_tree_show_icons = {
            \ 'git': 1,
            \ 'folders': 0,
            \ 'files': 0,
            \ 'folder_arrows': 0,
          \ }

          let g:nvim_tree_group_empty = 1

          lua << EOF
            require'nvim-tree'.setup {
              update_focused_file = {
                enable      = true,
                update_cwd  = true,
              },

              filters = {
                dotfiles = true,
              },

              view = {
                signcolumn = "no",
              },
            }
          EOF
        '';
      }
    ];

    extraPackages = with pkgs; [
      nodejs_latest
      lua
      ripgrep # For :Telescope live_grep
      xclip # For clipboard support
      ccls
      rnix-lsp
      clang-tools
    ];

    coc = {
      enable = true;

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
      set cmdheight=2
      set updatetime=300
      set signcolumn=yes
      set clipboard+=unnamedplus " For system clipboard support, needs xclip

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
      set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

      " Maps to insert a new line without going into insert mode
      nmap <S-Enter> O<Esc>
      nmap <CR> o<Esc>

      " Colorscheme options
      let $NVIM_TUI_ENABLE_TRUE_COLOR=1
      set termguicolors
      colorscheme tender
      let g:airline_theme = 'tender'

      " Tab config
      let bufferline = get(g:, 'bufferline', {})
      let bufferline.animation = v:false
      let bufferline.icons = v:false
      let bufferline.icon_close_tab = '●'

      nnoremap <silent> <s-f> :BufferPick<CR>
      nnoremap <silent> fw :BufferClose<CR>
      nnoremap <silent> fl :BufferNext<CR>
      nnoremap <silent> fh :BufferPrevious<CR>
      nnoremap <silent> fml :BufferMoveNext<CR>
      nnoremap <silent> fmh :BufferMovePrevious<CR>

      " Telescope config
      nnoremap <silent> tg :Telescope live_grep theme=ivy<CR>
      nnoremap <silent> tk :Telescope find_files theme=ivy<CR>
  
      " Pop up terminal config
      nnoremap <silent> <c-o> :ToggleTerm<CR>
      autocmd TermEnter term://*toggleterm#*
        \ tnoremap <silent> <c-o> <Cmd>exe v:count1 . "ToggleTerm"<CR>

      " Automatically changes pwd to git trees root
      let g:rooter_patterns = ['.git', '=${config.home.homeDirectory}/nix/nixpkgs' ]

      " Coc config
      set signcolumn=number
      autocmd CursorHold * silent call CocActionAsync('highlight')

      " Mappings for CoCList
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

