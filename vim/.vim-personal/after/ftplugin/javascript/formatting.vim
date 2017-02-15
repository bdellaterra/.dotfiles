
autocmd BufWritePost *.js silent !eslint_d --fix %
autocmd BufReadPost *.js SyntasticCheck
set autoread

