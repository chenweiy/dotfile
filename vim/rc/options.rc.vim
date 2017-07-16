"---------------------------------------------------------------------------
" Edit:
"
set nu "number
set cursorline 
set mouse=a
set backspace=2 "enable delete for mac
set fo-=r "close formatoptions -> not work ?
set ai "autoindent
set cindent "for c indent"

"set clipboard=unnamedplus
set clipboard=unnamed

" folding
set foldmethod=indent
setlocal foldlevel=1        " 设置折叠层数为
set foldlevelstart=99       " 打开文件是默认不折叠代码

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab "Converting tabs to spaces

" Ctags ------------------------------------------- "
set tags=tags;

"---------------------------------------------------------------------------
" Search: 
"
set ic " ignorecase
set incsearch
set hlsearch " highlight search

"---------------------------------------------------------------------------
" Color Scheme:
"
set t_Co=256
syntax enable

"monokai
"colorscheme monokai
"highlight Search term=reverse ctermfg=235 ctermbg=186 guifg=#272822 guibg=#e6db74

"solarized
let g:solarized_visibility = "high"
let g:solarized_contrast = "high"
let g:solarized_termcolors=16
set background=dark
colorscheme solarized

"---------------------------------------------------------------------------
" quickfix 
" 
"Automatically fitting a quickfix window height
"au FileType qf call AdjustWindowHeight(5, 10)
"function! AdjustWindowHeight(minheight, maxheight)
  "exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
"endfunction
