
autocmd BufWritePost *.js silent !eslint_d --fix %
autocmd BufReadPost *.js SyntasticCheck
set autoread

" let &formatprg='eslint_d --stdin --fix-to-stdout'

" Auto-format code on save, attempting to preserver cursor position
" autocmd BufWritePre *.js exe "normal! gggqG\<C-o>\<C-o>"

