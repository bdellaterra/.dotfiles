
let g:did_load_personal_config = 1

" Set preference for light vs. dark colorschemes
" (Used when choosing filetype-specific colorschemes)
let g:local.filetype_colors = 1
let g:local.background_pref = 'dark'

" Set default colorscheme
let g:local.default_colorscheme = 'greyman'
colorscheme greyman 

" Set the font
" set guifont=Liberation\ Mono\ 14
set guifont=InconsolataForPowerline\ Nerd\ Font\ 16

" Special paste w/ re-indent
map <leader>p "+gP'[V']="
imap <leader>p <C-o>"+gP<C-o>'[<C-o>V']=
vmap <leader>p x"+gP'[V']=

