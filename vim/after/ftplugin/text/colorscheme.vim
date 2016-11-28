
" 'Text' is the default filetype and uses the default colorscheme
let s:colorscheme = exists('g:local.default_filetype')
            \ ? g:local.default_filetype
            \ : 'greyman'
call DynamicColorScheme({
            \ 'gui_dark':   s:colorscheme,
            \ 'gui_light':  s:colorscheme,
            \ 'term_dark':  s:colorscheme,
            \ 'term_light': s:colorscheme,
            \ })


