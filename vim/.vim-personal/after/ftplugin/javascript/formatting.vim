
function! FormatJS()
    let save_pos = getpos(".")
    silent !eslint_d --fix %
    call setpos('.', save_pos)
    return 0
endfunction

autocmd BufWritePost *.js call FormatJS()
autocmd BufReadPost *.js SyntasticCheck
set autoread

" let &formatprg='eslint_d --stdin --fix-to-stdout'

" Auto-format code on save, attempting to preserver cursor position
" autocmd BufWritePre *.js exe "normal! gggqG\<C-o>\<C-o>"

