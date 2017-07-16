"---------------------------------------------------------------------------
" unite.vim
"

let g:unite_source_rec_max_cache_files = 0

let g:unite_data_directory='~/.unite/.cache/'
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

