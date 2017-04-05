
set autoread

" Runs eslint_d --fix asynchronously for better responsiveness.
" (But quick enough that conflicting changes are unlikely to be inserted
" before the job is done. Vim prompts with warning if necessary.)
function! AutoLint()
    silent! call job_start(['eslint_d', '--fix', expand('%')])
endfunction
autocmd BufWritePost *.js silent! call AutoLint()

" Autoread depends on file status being checked. This speeds that up
autocmd InsertEnter,CursorMoved,CursorMovedI,CursorHold,CursorHoldI * checktime
" Synchronous version: (No longer used)
" autocmd BufWritePost *.js silent !eslint_d --fix %

" No longer used:
"autocmd BufReadPost *.js SyntasticCheck
"let g:syntastic_javascript_checkers = ['eslint']
"let g:syntastic_javascript_eslint_exec = 'eslint_d'
"let g:syntastic_javascript_checkers = ['eslint']
"let g:syntastic_javascript_eslint_generic = 1
"let g:syntastic_javascript_eslint_exec = 'eslintme'

