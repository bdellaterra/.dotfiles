
setlocal iskeyword+=$
setlocal suffixesadd=.js,.jsx,.ts,.tsx
set path+=src

hi! link Conceal Statement
set concealcursor=n
if !exists('b:save_conceallevel') || b:save_conceallevel
  if !&conceallevel
    call ToggleConceal()
  endif
endif

" Auto-fold long imports
silent! %g#^import#normal zc

