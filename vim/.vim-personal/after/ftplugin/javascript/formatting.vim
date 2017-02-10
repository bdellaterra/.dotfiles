
function! FormatJS() range
    let save_pos = getpos(".")
    exe 'silent ' . a:firstline . ',' . a:lastline
        \ . '!prettier --stdin 2>/dev/null | eslint_d --stdin --fix-to-stdout 2>/dev/null'
    call setpos('.', save_pos)
    return 0
endfunction

let &formatprg='eslint_d --stdin --fix-to-stdout'

" Auto-format code on save, attempting to preserver cursor position
autocmd BufWritePre *.js exe "normal! gggqG\<C-o>\<C-o>"
set autoread

