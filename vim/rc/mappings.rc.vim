"---------------------------------------------------------------------------
" Key-mappings:

nmap <space>qq :q<CR>

map <space>j <C-W>j
map <space>k <C-W>k
map <space>h <C-W>h
map <space>l <C-W>l

nnoremap <C-l> :nohlsearch<CR><C-l>
"nmap <space>w <Plug>(easymotion-bd-w)
nmap <space>q :cclose<CR>

" preview-windows ---------------"
map <space>] <C-w>}
map <space>z <C-w>z

map <space>i [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

" gtags map --------------------- "
nmap <space>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <space>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <space>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <space>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <space>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <space>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
"nmap <space>i :cs find i <C-R>=expand("<cfile>")<CR><CR>

if has('nvim')
"nmap <space>` :terminal<CR>
"tnoremap <ESC>   <C-\><C-n>
endif
