" Download plugins in this directory
call plug#begin('~/.vim/plugged')

" Plugins
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'rust-lang/rust.vim'
Plug 'jampow/vim-arc-dark-theme'
Plug 'mboughaba/i3config.vim'
call plug#end()

" Map CTRL+n to toggle NERDTree
map <silent> <C-n> :NERDTreeToggle<CR>
"ignore files in NERDTree
let NERDTreeIgnore=['\.pyc$', '\~$', '__pycache__'] 
" Set NERDTree windows size
let NERDTreeWinSize=20

" Automatically save and run python3 scripts when pressing F5 
autocmd Filetype python nnoremap <buffer> <F5> :w<CR>:vert ter python3 "%"<CR>

" Enable syntax highlighting for the i3 config file
aug i3config_ft_detection
	au!
	au BufNewFile,BufRead ~/.config/i3/config set filetype=i3config
aug end

" Maps to insert a new line without going into insert mode
nmap <S-Enter> O<Esc>
nmap <CR> o<Esc>

" Colorscheme options
let g:spacegray_use_italics = 1
let g:spacegray_underline_search = 1
highlight Normal ctermfg=grey ctermbg=darkblue
colorscheme arc-dark

" Some basic config
set tabstop=4
let python_highlight_all=1
syntax on
set number
set relativenumber
set mouse=a
