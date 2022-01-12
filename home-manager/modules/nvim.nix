{ pkgs, config, ... }:

{
  # TODO: add https://github.com/nvim-telescope/telescope.nvim for a grep with preview.
  # Also maybe https://github.com/akinsho/toggleterm.nvim? seems useful.
  programs.neovim = {
    enable = true;
  
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  
    plugins = with pkgs.vimPlugins; [
      nerdtree
      barbar-nvim
      airline
      iceberg-vim

      coc-nvim
      vim-nix
      limelight-vim
      goyo-vim
    ];

    extraPackages = with pkgs; [
      nodejs_latest
      ccls
      rnix-lsp
    ];
  
    coc = {
      enable = true;
      settings = {
        suggest.enablePreview = true;
        suggest.enablePreselect = false;
        client.snippetSupport = true;
        languageserver = {
          nix = {
            command = "rnix-lsp";
            filetypes = [ "nix" ];
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
            ];
          };
        };
      };
    };
  
    extraConfig = ''
      syntax on
      set relativenumber
      set number
      set tabstop=8
      set mouse=a
      set cmdheight=2
      set updatetime=300
      set signcolumn=yes
      set clipboard+=unnamedplus
      let python_highlight_all=1

      " Maps to insert a new line without going into insert mode
      nmap <S-Enter> O<Esc>
      nmap <CR> o<Esc>

      " Colorscheme options
      set t_Co=256
      set termguicolors
      colorscheme iceberg

      " Tab config
      let bufferline = get(g:, 'bufferline', {})
      let bufferline.animation = v:false
      let bufferline.icons = v:false
      let bufferline.icon_close_tab = '●'

      nnoremap <c-h> :BufferPrevious<CR>
      nnoremap <c-l> :BufferNext<CR>
      nnoremap <c-w> :BufferClose<CR>
  
      " NERDTree config
      let NERDTreeIgnore=['\.pyc$', '\~$', '__pycache__']
      let NERDTreeWinSize=21
  
      map <silent> <C-n> :NERDTreeToggle<CR>
      autocmd VimEnter * NERDTree | wincmd p
  
      " Close the tab if NERDTree is the only window remaining in it.
      autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
  
      " Open the existing NERDTree on each new tab.
      autocmd BufWinEnter * if getcmdwintype() == ${"''"} | silent NERDTreeMirror | endif
  
      " Writing mode
      autocmd! User GoyoEnter Limelight
      autocmd! User GoyoLeave Limelight!
      map <F2> <ESC>:Limelight!! <bar> :Goyo <CR>
      
      " Completion
      inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()
  
      inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
  
      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
      endfunction
  
      autocmd CursorHold * silent call CocActionAsync('highlight')
      inoremap <silent><expr> <c-space> coc#refresh()
    '';
  };
}
