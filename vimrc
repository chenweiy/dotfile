set fillchars=vert:│,fold:─
let g:vimfiler_tree_leaf_icon = "⋮"
let g:vimfiler_tree_opened_icon = "▼"
let g:vimfiler_tree_closed_icon = "▷"

"dein Scripts-----------------------------
if &compatible  
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('~/.cache/dein')  
  call dein#begin('~/.cache/dein')

  " Let dein manage dein
  " Required:
  call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here:
  call dein#add('Shougo/deoplete.nvim', {
        \ 'lazy': 1,
        \ 'on_i': 1})
  call dein#add('Shougo/neosnippet.vim', {
        \ 'lazy': 1,
        \ 'on_i': 1})
  call dein#add('Shougo/neosnippet-snippets', {
        \ 'lazy': 1,
        \ 'depends': 'neosnippet.vim',
        \ 'on_i': 1})
  call dein#add('Shougo/vimfiler.vim',  { 'depends': 'unite.vim' })

  call dein#add('scrooloose/nerdcommenter', {'on_map': {'n': ['\cc', '\cu']}})   " commenter: \cc \cu
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  call dein#add('Yggdroot/indentLine')
  call dein#add('mileszs/ack.vim', {'on_cmd': 'Ack'})
  call dein#add('easymotion/vim-easymotion', {
      \ 'lazy': 1,
      \ 'on_map': ['<Plug>(easymotion-bd-w)']})

  " unite --------------------------- "
  call dein#add('Shougo/denite.nvim')
  call dein#add('Shougo/unite.vim', {
      \ 'on_cmd': ['Unite']})
  call dein#add('Shougo/neomru.vim', {
      \ 'depends' : 'Shougo/denite.nvim'})
  call dein#add('Shougo/unite-outline',{
      \ 'depends' : 'Shougo/unite.vim'})

  call dein#add('aceofall/gtags.vim')

  " Rst --------------------------- "
  call dein#add('Rykka/riv.vim', { 'on_ft' : 'rst' })
  call dein#add('Rykka/InstantRst', { 'on_ft' : 'rst' })

  " Syntax highlight --------------------------- "
  call dein#add('octol/vim-cpp-enhanced-highlight', { 'on_ft' : 'c' })

  " Ultisnips ---------------------------------- ""
  call dein#add( 'tpope/vim-surround', {'on_map': {'n' : ['cs', 'ds', 'ys'], 'x' : 'S'}})

  " Substitute Preview
  call dein#add('osyo-manga/vim-over', { 'on_cmd' : 'OverCommandLine' })

  " Python
  "call dein#add('klen/python-mode', { 'on_ft' : 'python' }) 

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on  
syntax enable

" If you want to install not installed plugins on startup.
"if dein#check_install()
"  call dein#install()
"endif

"End dein Scripts-------------------------

" Use deoplete.
let g:deoplete#enable_at_startup = 1
set nu "number
set cursorline 
set mouse=a
set backspace=2 "enable delete for mac
set fo-=r "close formatoptions -> not work ?

" tab ------------------------------------------------" 
set ai "autoindent
set cindent "for c indent"

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab "Converting tabs to spaces

" search ------------"" 
set ic " ignorecase
set incsearch
set hlsearch " highlight search

"set clipboard=unnamedplus
set clipboard=unnamed

" folding
set foldmethod=indent
setlocal foldlevel=1        " 设置折叠层数为
set foldlevelstart=99       " 打开文件是默认不折叠代码

" Ctags ------------------------------------------- "
set tags=tags;

" map ---------------------------------------------- "
nmap <space>qq :q<CR>

map <space>j <C-W>j
map <space>k <C-W>k
map <space>h <C-W>h
map <space>l <C-W>l

map <F2> :Tlist<CR> 
"map <C-b> :NERDTreeTabsToggle<CR>
nnoremap <C-l> :nohlsearch<CR><C-l>
nmap <space>w <Plug>(easymotion-bd-w)
nmap <space>q :cclose<CR>

nnoremap <space>p :Denite -mode=normal file_mru file<CR>
nnoremap <space>b :Denite -mode=normal buffer<CR>
"nnoremap <space>o :Denite -mode=normal outline<CR>
nnoremap <space>o :Unite outline<CR>
nnoremap <space>x :Denite -mode=normal grep<CR>

"color Scheme ------------------------------------------------ "
set t_Co=256
syntax enable

"monokai
"colorscheme monokai
"highlight Search term=reverse ctermfg=235 ctermbg=186 guifg=#272822 guibg=#e6db74

"solarized
let g:solarized_visibility = "high"
let g:solarized_contrast = "high"
"let g:solarized_termtrans = 1
let g:solarized_termcolors=16
"let g:solarized_termcolors=256
set background=dark
"set background=light

colorscheme solarized

" vim-airline -------------------------------------------------------- "
" set status line
set laststatus=2
" enable powerline-fonts
let g:airline_powerline_fonts = 1
let g:airline#extensions#whitespace#enabled = 0
"let g:airline_theme='wombat'
let g:airline_theme='solarized'

" UltiSnips -------------------------------------------------------- "
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
"let g:UltiSnipsExpandTrigger="<C-j>"
"let g:UltiSnipsJumpForwardTrigger="<C-j>"
"let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
"let g:UltiSnipsEditSplit="vertical"

" indent ------------------------------------------------------------- "
let g:indentLine_char = '┆'
"let g:indentLine_color_term = 11

" gtags ------------------------------------------------------------- "
set cscopetag
set cscopeprg='gtags-cscope'
let GtagsCscope_Auto_Load = 1
let GtagsCscope_Auto_Map = 1
let GtagsCscope_Quiet = 1

" restructure ------------------------------------------------------- "
let g:riv_disable_folding = 1
let g:instant_rst_localhost_only = 1

" YouCompleteMe ----------------------------------------------- "
"let g:ycm_python_binary_path = 'python'
"let g:ycm_global_ycm_extra_conf = "~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py"
"let g:ycm_show_diagnostics_ui = 0
"let g:ycm_error_symbol = '>>'
"let g:ycm_warning_symbol = '>*'

" Python highlight --------------------------------------------- "
augroup python
    autocmd!
    autocmd FileType python
                \   syn keyword pythonSelf self
                \ | highlight def link pythonSelf Number
augroup end

" TMUX --------------------------------------------------------- "
"if exists('$TMUX')
  "set term=screen-256color
"endif

"unite.vim config ----------------------------------------------- "
let g:unite_source_rec_max_cache_files = 0

"let g:unite_data_directory='~/.unite/.cache/'
"let g:unite_split_rule = "botright"
let g:unite_source_file_rec_max_cache_files = 3000
"let g:unite_enable_start_insert = 1
"let g:unite_force_overwrite_statusline = 0
"let g:unite_winheight =10
"let g:unite_source_history_yank_enable = 1
let g:unite_prompt='>> '
"call unite#filters#matcher_default#use(['matcher_fuzzy'])
"call unite#filters#sorter_default#use(['sorter_rank'])
"call unite#custom#profile('files', 'filters', 'sorter_rank')
"call unite#custom#source('file_mru,file_rec,file_rec/async,grepocate', 'max_candidates', 3000)

" quickfix ------------------------------------------------------- " 
"Automatically fitting a quickfix window height
"au FileType qf call AdjustWindowHeight(5, 10)
"function! AdjustWindowHeight(minheight, maxheight)
  "exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
"endfunction

" coding style ---------------------------------------------------- "
autocmd BufRead,BufNewFile *.{md,mdown,mkd} set filetype=markdown

" c
autocmd BufRead,BufNewFile   *.c,*.h
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set expandtab |

" python
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set fileformat=unix |

au BufNewFile,BufRead *.js,*.html,*.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2 |

autocmd FileType make setlocal noexpandtab
autocmd FileType markdown set noexpandtab

let g:ConqueTerm_Color = 1

" ==========================================================
"   pymode 
" ==========================================================
let g:pymode_python = 'python3'
let g:pymode_doc = 1
let g:pymode_doc_bind = 'K'
let g:pymode_run = 1
let g:pymode_run_bind = '<leader>r'
"let g:pymode_lint_on_write = 0

" ==========================================================
"   neocomplete
" ==========================================================
" Disable AutoComplPop.
"let g:acp_enableAtStartup = 0
"" Use neocomplete.
"let g:neocomplete#enable_at_startup = 1
"" Use smartcase.
"let g:neocomplete#enable_smart_case = 1
"" Set minimum syntax keyword length.
"let g:neocomplete#sources#syntax#min_keyword_length = 3

"" Define dictionary.
"let g:neocomplete#sources#dictionary#dictionaries = {
    "\ 'default' : '',
    "\ 'vimshell' : $HOME.'/.vimshell_hist',
    "\ 'scheme' : $HOME.'/.gosh_completions'
        "\ }

"" Define keyword.
"if !exists('g:neocomplete#keyword_patterns')
    "let g:neocomplete#keyword_patterns = {}
"endif
"let g:neocomplete#keyword_patterns['default'] = '\h\w*'

"" Plugin key-mappings.
"inoremap <expr><C-g>     neocomplete#undo_completion()
"inoremap <expr><C-l>     neocomplete#complete_common_string()

"" Recommended key-mappings.
"" <CR>: close popup and save indent.
"inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
"function! s:my_cr_function()
  "return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  "" For no inserting <CR> key.
  ""return pumvisible() ? "\<C-y>" : "\<CR>"
"endfunction
"" <TAB>: completion.
"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
"" <C-h>, <BS>: close popup and delete backword char.
"inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
"inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
"" Close popup by <Space>.
""inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

"" AutoComplPop like behavior.
""let g:neocomplete#enable_auto_select = 1

"" Shell like behavior(not recommended).
""set completeopt+=longest
""let g:neocomplete#enable_auto_select = 1
""let g:neocomplete#disable_auto_complete = 1
""inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

"" Enable omni completion.
"autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

"" Enable heavy omni completion.
"if !exists('g:neocomplete#sources#omni#input_patterns')
  "let g:neocomplete#sources#omni#input_patterns = {}
"endif
""let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
""let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
""let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

"" For perlomni.vim setting.
"" https://github.com/c9s/perlomni.vim
"let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'


" ==========================================================
"   neosnippet
" ==========================================================
" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <TAB>     <Plug>(neosnippet_expand_or_jump)
xmap <TAB>     <Plug>(neosnippet_expand_target)

"imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif


" ==========================================================
"   ACK
" ==========================================================
let g:ackprg = 'ag --vimgrep'

" Ag command on grep source
call denite#custom#var('grep', 'command', ['ag'])
call denite#custom#var('grep', 'default_opts',
        \ ['-i', '--vimgrep'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', [])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])


inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ deoplete#mappings#manual_complete()
function! s:check_back_space() abort "{{{
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}

let g:vimfiler_as_default_explorer = 1

