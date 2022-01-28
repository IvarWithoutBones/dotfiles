{ pkgs, config, ... }:

{
  programs.neovim = {
    enable = true;
  
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  
    plugins = with pkgs.vimPlugins; [
      barbar-nvim
      nerdtree
      toggleterm-nvim
      coc-nvim

      vim-rooter
      vim-nix

      airline
      tender-vim
      telescope-nvim
      plenary-nvim # Dependency of telescope
      {
        plugin = telescope-frecency-nvim;
        type = "lua";
        config = ''require"telescope".load_extension("frecency")'';
      } {
        plugin = sqlite-lua;
        config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'";
      }
    ];

    extraPackages = with pkgs; [
      nodejs_latest
      lua
      ripgrep # For :Telescope live_grep
      ccls
      rnix-lsp
      xclip # For clipboard support
    ];

    coc = {
      enable = true;
      settings = {
        suggest = {
          enablePreview = true;
          noselect = true;
          enablePreselect = false;
        };
        client.snippetSupport = true;
        languageserver = {
          nix = {
            command = "rnix-lsp";
            filetypes = [ "nix" ];
            rootPatterns = [
              "flake.lock"
              ".git"
            ];
          };
          cpp = {
            command = "ccls";
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
              ".git"
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
      nnoremap <silent> th :Telescope frecency frecency theme=ivy<CR> # History files

      " NERDTree config
      let NERDTreeMinimalUI = v:true
      let NERDTreeStatusline="" " Removes the statusline
      let NERDTreeIgnore=['\.pyc$', '\~$', '__pycache__']
      let NERDTreeWinSize=21

      " NERDTree sometimes won't let you close it when its focused, so we need to unfocus it first.
      " We can probably do this from the mapping, but I have no clue how.
      function Toggle_NERDTree()
        if &filetype ==# 'nerdtree'
          :wincmd p
        endif
        :NERDTreeToggle
      endfunction

      map <silent> <c-b> :call Toggle_NERDTree()<CR>
      map <silent> <c-n> :wincmd p<CR>

      autocmd VimEnter * NERDTree | wincmd p
  
      " Close the tab if NERDTree is the only window remaining in it.
      autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
  
      " Open the existing NERDTree on each new tab.
      autocmd BufWinEnter * if getcmdwintype() == ${"''"} | silent NERDTreeMirror | endif
      
      " Pop up terminal config
      nnoremap <silent> <c-o> :ToggleTerm<CR>
      autocmd TermEnter term://*toggleterm#*
        \ tnoremap <silent> <c-o> <Cmd>exe v:count1 . "ToggleTerm"<CR>

      " Automatically cd's into project root, as to
      let g:rooter_patterns = ['.git', '=${config.home.homeDirectory}/nix/nixpkgs' ]

      " Coc config
      set signcolumn=number
      autocmd CursorHold * silent call CocActionAsync('highlight')

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

