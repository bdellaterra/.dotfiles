"let g:syntastic_javascript_checkers = ['eslint']
"let g:syntastic_javascript_eslint_exec = 'eslint_d'

" let g:syntastic_javascript_checkers = ['eslint']
" let g:syntastic_javascript_eslint_generic = 1
" let g:syntastic_javascript_eslint_exec = 'eslintme'

autocmd BufWritePost *.js silent !eslint_d --no-color --cache --fix %
" autocmd BufReadPost *.js SyntasticCheck
set autoread

