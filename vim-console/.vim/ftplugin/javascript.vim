
" Set eslint executable (daemons are faster)
if executable('eslint_d')
  let b:ale_javascript_eslint_executable = 'eslint_d'
endif
if executable('eslintme')
  let b:ale_javascript_eslint_executable = 'eslintme'
endif

" Support autofix using prettier and/or ESLint
let b:ale_fixers = []
if ($EDITOR_AUTO_PRETTIFY || $EDITOR_AUTO_PRETTIFY == '')
    let b:ale_fixers += ['prettier']
endif
if ($EDITOR_AUTO_FIX || $EDITOR_AUTO_FIX == '')
    let b:ale_fixers += ['eslint']
endif

