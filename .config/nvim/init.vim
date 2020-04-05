" Download plugins in this directory
call plug#begin('/home/ivar/.vim/plugged')

" Plugins
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'mboughaba/i3config.vim'
Plug 'preservim/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'itchyny/lightline.vim'
Plug 'LnL7/vim-nix'
Plug 'rust-lang/rust.vim'

" Autocomplete
Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-vim'
Plug 'Shougo/neco-vim'
call plug#end()

" Map CTRL+n to toggle NERDTree
map <silent> <C-n> :NERDTreeToggle<CR>
"ignore files in NERDTree
let NERDTreeIgnore=['\.pyc$', '\~$', '__pycache__'] 
" Set NERDTree windows size
let NERDTreeWinSize=20

" Automatically save and run python3 scripts when pressing F5 
autocmd Filetype python nnoremap <buffer> <F5> :w<CR>:vert ter python3 "%"<CR>
autocmd Filetype rust nnoremap <buffer> <F5> :w<CR>:vert ter cargo run ..<CR>

imap <c-space> <Plug>(asyncomplete_force_refresh)

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"

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
colorscheme dracula

" Some basic config
autocmd BufEnter * call ncm2#enable_for_buffer()
set completeopt=noinsert,menuone,noselect
set tabstop=4
let python_highlight_all=1
let g:deoplete#enable_at_startup = 1
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
