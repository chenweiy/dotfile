" ==========================================================
"   dein configuration
" ==========================================================

" Required:
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('~/.cache/dein')  
  call dein#begin('~/.cache/dein')

  call dein#load_toml('~/.vim/rc/dein.toml', {'lazy': 0})
  call dein#load_toml('~/.vim/rc/deinlazy.toml', {'lazy': 1})

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

