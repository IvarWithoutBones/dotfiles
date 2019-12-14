" Download plugins in this directory
call plug#begin('~/.vim/plugged')

" Plugins
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'rust-lang/rust.vim'
Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }
Plug 'mboughaba/i3config.vim'
Plug 'LnL7/vim-nix'
call plug#end()

" Map CTRL+n to toggle NERDTree
map <silent> <C-n> :NERDTreeToggle<CR>
"ignore files in NERDTree
let NERDTreeIgnore=['\.pyc$', '\~$', '__pycache__'] 
" Set NERDTree windows size
let NERDTreeWinSize=20

" Automatically save and run python3 scripts when pressing F5 
autocmd Filetype python nnoremap <buffer> <F5> :w<CR>:vert ter python3 "%"<CR>
autocmd Filetype cs nnoremap <buffer> <F5> :w<CR>:vert ter dotnet run<CR>
autocmd Filetype rust nnoremap <buffer> <F5> :w<CR>:vert ter cargo run ..<CR>

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
colorscheme challenger_deep

" Some basic config
set tabstop=4
let python_highlight_all=1
syntax on
set number
set relativenumber
set tabstop=8
set mouse=a

" Enable block cursor
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"
