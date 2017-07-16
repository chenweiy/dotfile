"---------------------------------------------------------------------------
" Filetype:
"
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

"---------------------------------------------------------------------------
" Python highlight 
"
augroup python
    autocmd!
    autocmd FileType python
                \   syn keyword pythonSelf self
                \ | highlight def link pythonSelf Number
augroup end
