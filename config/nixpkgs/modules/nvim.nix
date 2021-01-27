{ pkgs, ... }: {

programs.neovim = {
  enable = true;

  viAlias = true;
  vimAlias = true;
  vimdiffAlias = true;

  plugins = with pkgs.vimPlugins; [
    papercolor-theme
    nerdtree
    vim-nerdtree-tabs
    lightline-vim
    vim-polyglot
    limelight-vim
    goyo-vim

    # Autocomplete
    nvim-yarp
    neco-vim
    ncm2
    ncm2-bufword
    ncm2-path
  ];
  
  extraConfig = ''
    " NERDTree config
    map <silent> <C-n> :NERDTreeToggle<CR>
    let NERDTreeIgnore=['\.pyc$', '\~$', '__pycache__']
    let NERDTreeWinSize=20
    
    " Automatically save and run code when pressing F5
    autocmd Filetype python nnoremap <buffer> <F5> :w<CR>:!python3 "%"<CR>
    autocmd Filetype sh nnoremap <buffer> <F5> :w<CR>:!"./%"<CR>
    autocmd Filetype rust nnoremap <buffer> <F5> :w<CR>:!cargo run ..<CR>
    autocmd Filetype nix nnoremap <buffer> <F5> :w<CR>:!nix-build -E '((import <nixpkgs> {}).callPackage (import ./%) { })'<CR>
    
    imap <c-space> <Plug>(asyncomplete_force_refresh)
    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"
    
    " Maps to insert a new line without going into insert mode
    nmap <S-Enter> O<Esc>
    nmap <CR> o<Esc>

    " Writing mode
    autocmd! User GoyoEnter Limelight
    autocmd! User GoyoLeave Limelight!
    map <F2> <ESC>:Limelight!! <bar> :Goyo <CR>
    
    " Colorscheme options
    set t_Co=256
    set background=dark
    colorscheme PaperColor
    
    " ncm2 config
    autocmd BufEnter * call ncm2#enable_for_buffer()
    set completeopt=noinsert,menuone,noselect
    inoremap <c-c> <ESC>

    " Some basic config
    syntax on
    let python_highlight_all=1
    set relativenumber
    set number
    set tabstop=8
    set mouse=a
  '';
}; }
