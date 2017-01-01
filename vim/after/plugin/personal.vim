
let g:did_load_personal_config = 1

" Set preference for light vs. dark colorschemes
" (Used when choosing filetype-specific colorschemes)
let g:local.filetype_colors = 1
let g:local.background_pref = 'dark'

" Set default colorscheme
let g:local.default_colorscheme = 'greyman'
colorscheme greyman 
" (Dark Colorschemes)
" 0x7A69_dark
" abra
" antares
" alduin (term)
" anderson (term)
" apprentice (term)
" argonaut
" CandyPaper
" denim
" desert256
" desertedocean
" desertedoceanburnt
" desertink
" deveiate
" distinguished
" dusk
" ecostation
" gotham
" hilal
" iceberg
" jammy
" jellybeans
" jellyx
" kellys
" luinnar
" less
" lodestone
" lxvc
" manxome
" mustang
" nazca
" neverland
" neverland-darker
" neverness (term)
" oxeded
" underwater-mod
" wolfpack (term)
"
" (Medium Colorschemes)
" greyman
"
" (Light Colorschemes)
" delphi
" disciple (term)
" donbass (term)
" dull
" earendel
" github
" lightning (term)
" PaperColor (term)

" Set the font
" set guifont=Liberation\ Mono\ 14
set guifont=InconsolataForPowerline\ Nerd\ Font\ 16

" Special paste w/ re-indent
map <leader>p "+gP'[V']="
imap <leader>p <C-o>"+gP<C-o>'[<C-o>V']=
vmap <leader>p x"+gP'[V']=

