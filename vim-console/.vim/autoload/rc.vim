if &cp || exists("g:loaded_rc_plugin")
 finish
endif
let g:loaded_rc_plugin = "v01"
let s:keepcpo        = &cpo
set cpo&vim

" Remove whitespace from beginning and ending of a string
" (Native Vim function not available before version 8.0.1630)
function! rc#trim(var)
  return substitute(substitute(a:var, '^\s*', '', ''), '\s*$', '', '')
endfunction

" Convert path to forward slashes with a slash at the end
function rc#DirSlashes(path)
  return substitute(a:path, '[^/\\]\@<=$\|\\', '/', 'g')
endfunction

" Create directory if necessary and normalize slashes
function rc#MakeDir(path)
  try
    if !isdirectory(a:path) && exists('*mkdir')
      call mkdir(a:path, 'p')
    endif
  endtry
  return rc#DirSlashes(a:path)
endfunction

" Create file if necessary and normalize slashes
function rc#MakeFile(path, ...)
  try
    let file = fnamemodify(a:path, ':t')
    let dir = rc#DirSlashes(fnamemodify(a:path, ':h'))
    let bufferDir = rc#DirSlashes(fnamemodify(expand('%'), ':p:h'))
    let projectDir = rc#DirSlashes(fnamemodify(get(a:000, 0, $PWD), ':p'))
    " full path
    if dir =~ bufferDir
      let targetDir = dir
    " relative path
    elseif dir =~ '^\V..\?/'
      let targetDir = rc#DirSlashes(fnamemodify(bufferDir . dir, ':.'))
    " existing project path
    elseif isdirectory(projectDir . dir)
      let targetDir = projectDir . dir
    " just filename
    elseif dir == '' && isdirectory(bufferDir)
      let targetDir = bufferDir
    endif
    if exists('targetDir') " variable named 'targetDir' exists
      call rc#MakeDir(targetDir)
      let file = targetDir . file
      if filewritable(file)
        call writefile([], file, 'a')
      endif
    endif
  endtry
  return file
endfunction

" Get full file path for current buffer or # buffer if command-count provided
function rc#BufferFile(...)
  let fnameMods = get(a:000, 0, '')
  return expand((v:count ? '#'.v:count : '%') . ':p' . fnameMods)
endfunction

function rc#File(file)
 let file = fnamemodify(fnameescape(a:file), ':p')
 if filereadable(file) || isdirectory(file)
   return file
 endif
 return ''
endfunction

function rc#SearchFile(file, searchTerm)
  exe 'edit ' . File(a:file)
  call search(a:searchTerm, 'cw')
endfunction

" If current file has no extension, add the one supplied as first argument
function rc#AddMissingFileExtension(ext)
  let g:extension = a:ext
  if a:ext != '' && fnamemodify(expand("%"), ":e") == ''
    try
      exe 'Gmove ' . fnameescape(expand('%:p')) . a:ext
    catch
      exe 'saveas %' . a:ext
      bdelete #
      call delete(expand('%:r'))
    endtry
  endif
endfunction

" Establish lost settings after session reload
function rc#OnSessionLoaded()
  if get(b:, 'isRestoredSession', 0)
    call rc_status#SetDefaultStatusModeHLGroups()
    " re-edit file to invoke filetype and git branch (via fugitive)
    call feedkeys(':e')
    unlet b:isRestoredSession
  endif
endfunction

" Calculate ideal position for cursor to settle during scrolling
function! rc#CursorRatio()
  return float2nr(round(winheight(0) * 0.381966))
endfunction

" Check whether the sign column is active
function rc#IsSignColumnActive()
  return &signcolumn == 'yes'
    \ || &signcolumn == 'auto' && len(sign_getplaced())
endfunction

" Determine maximum line width accounting for left-side gutters
function rc#MaxLineWidth()
  return winwidth(0)
    \ - (rc#IsSignColumnActive() ? 2 : 0)
    \ - (&number ? len(line('$')) + 1 : 0)
endfunction

" Show syntax group and translated syntax group of character under cursor
" Will look at syntax v:count lines below cursor if a count is specified
" If optional boolean true is passed, will look v:count lines above cursor
" (Modified) From Laurence Gonsalves, 2016, https://stackoverflow.com/questions/9464844/how-to-get-group-name-of-highlighting-under-cursor-in-vim
function! rc#SynGroup(...)
  let reverse = get(a:000, 0, 0)
  let l:s = synID(line('.') + v:count * (reverse ? -1 : 1), col('.'), 1)
  return synIDattr(l:s, 'name') . ' ->  ' . synIDattr(synIDtrans(l:s), 'name')
endfunction

" Move cursor through next whitespace in current column. Lands on non-whitespace
" character after the gap. Optional boolean triggers backwards search if true
function rc#GoToNextVerticalNonBlank(...)
  let reverse = get(a:000, 0, 0)
  let col = virtcol('.') 
  let lastsearch=@/
  let blank = 1
  while blank
    call search('\(^\s*$\)\|\%' . col . 'v\s', reverse ? 'b' : '')
    call search('\%' . col . 'v\S', reverse ? 'b' : '')
    let blank = rc#SynGroup() =~ '\<Ignore$'
  endwhile
  let @/=lastsearch
endfunction


" BUFFERS

" Move forward/backward in the list of Most Recently Used files
function! rc#JumpMRU(...)
  if !exists('g:mruJump') | let g:mruJump = 0 | endif
  if !exists('g:mruIndex') | let g:mruIndex = 0 | endif
  if !exists('g:mruFiles') | let g:mruFiles = [] | endif
  let delta = get(a:000, 0, -1)
  let g:mruFiles = len(g:mruFiles) > 0
    \ ? g:mruFiles
    \ : map(
    \   fzf_mru#mrufiles#list(),
    \   "fnamemodify(filereadable(v:val) ? v:val : ProjectRootGuess() . '/' . v:val, ':p')"
    \ )
  let g:mruIndex = max([0, g:mruIndex - delta])
  let g:mruIndex = min([g:mruIndex, len(g:mruFiles) - 1])
  echo g:mruIndex . ': ' . g:mruFiles[g:mruIndex]
  let g:mruJump = 1
  silent! exe 'silent! buffer ' .  g:mruFiles[g:mruIndex]
  let g:mruJump = 0
endfunction

" Overload behavior of the equals key
function rc#EditBufferOrReindent(...)
  let bufNum = get(a:000, 0, '')
  if bufNum == ''
    return "="
  elseif bufNum == 0
    if fnamemodify(expand('#'), ':p') == fnamemodify(expand('%'), ':p')
      " fallback to most recently used filed if no alternate buffer is defined
      return ":\<C-u>edit " . fzf_mru#mrufiles#list()[0] . "\<CR>"
    endif
    return ":\<C-u>confirm buffer #\<CR>"
  else
    return ":\<C-u>confirm buffer" . bufNum . "\<CR>"
  endif
  return ""
endfunction

" Switch to alternate buffer, or if none defined switch to most recently used file
function rc#SwitchToAltBufferOrMruFile()
  if fnamemodify(expand('#'), ':p') == fnamemodify(expand('%'), ':p')
    exe 'edit ' . fzf_mru#mrufiles#list()[1]
  else
    confirm buffer #
  endif
endfunction


" CLIPBOARD

" Share yanked text with system clipboard, even when Vim lacks 'clipboard' support
function rc#CopyToClipboard(text, ...)
  let register = get(a:000, 0, '')
  if !has('clipboard')
    if exists('s:clipCopy') && register == ''
      call system(s:clipCopy, a:text)
    endif
  else
    call setreg('+', a:text)
  endif
  if exists('*state') && state() !~ 'x' && register != ''
    call setreg(register, a:text)
  endif
  return a:text
endfunction

" Sync system clipboard with Vim for paste-support
function rc#PasteFromClipboard()
  if exists('s:clipPaste')
    let @" = system(s:clipPaste)
  endif
endfunction


" PAGER

function rc#LessInitFunc()
  let g:disableSessionManager = 1
  let g:disableToggleConceal = 1
  " augroup! SessionManager
  AnsiEsc
  au VimEnter * normal gg
endfunction


" NOTES

" Calling this at end of script so any added paths can be captured
function rc#AutoAddMarkdownExtensionToNotes()
  let g:nv_glob_paths = join(map(copy(g:nv_search_paths), 'v:val . "/*/*"'), ',')
  augroup MarkdownNotes
    au!
    exe 'autocmd BufEnter ' . g:nv_glob_paths . ' if &ft=="" | edit | endif'
    exe 'autocmd BufWrite ' . g:nv_glob_paths . ' call rc#AddMissingFileExtension(".md")'
  augroup END
endfunction


" VERSION CONTROL

" List git branches from command-completion
function! rc#ListBranches(...)
   let argLead = get(a:000, 0, '')
   let g:branches = system("git branch -a --no-color | grep -v '^\* ' ")
   let trimmed = map(split(g:branches, '\n'), 'trim(v:val)')
   return filter(trimmed, 'v:val =~ "^'. argLead . '"') 
endfunction


" CONCEALMENT

" Returns true if cursor is currently over a concealed syntax region
function rc#IsCursorOverConcealed()
  return synconcealed(line('.'), col('.'))[0]
endfunction

" Toggle between conceallevel 0 and 2. Pass optional boolean
" false to disable temporarily, or true to restore last on/off setting
function rc#ReinforceConcealSyntax()
  if !exists('g:disableConcealSyntax') || !g:disableConcealSyntax
    if &conceallevel
      silent! exe 'source ~/.dotfiles/vim-console/.vim/after/syntax/' . &filetype . '.vim'
    endif
  endif
endfunction
function rc#UpdateTime(...)
  if !exists('g:disableConcealSyntax') || !g:disableConcealSyntax
    let newUpdateTime = get(a:000, 0, 0)
    if newUpdateTime && newUpdateTime != &updatetime
      let g:restoreUpdateTime = &updatetime
      let &updatetime = newUpdateTime
    elseif exists('g:restoreUpdateTime')
      let &updatetime = g:restoreUpdateTime
      unlet g:['restoreUpdateTime']
    endif
  endif
endfunction
function rc#RevealLine(...)
  let l:save_view = winsaveview()
  if !exists('g:enableConcealAtCursor') || !g:enableConcealAtCursor
    set concealcursor=
  elseif !exists('g:disableConcealSyntax') || !g:disableConcealSyntax
    let unconcealLine = get(a:000, 0, 0)
    if unconcealLine
      set concealcursor=
    else
      set concealcursor=n
    endif
  endif
  call winrestview(l:save_view)
endfunction
function rc#ToggleConceal(...)
  let save_lazyredraw = &lazyredraw
  set lazyredraw
  if !exists('g:disableConcealSyntax') || !g:disableConcealSyntax
    let tmpToggle = get(a:000, 0, 0)
    if !exists('b:save_conceallevel')
      let b:save_conceallevel = &conceallevel
    endif
    if len(a:000)
      let &conceallevel = tmpToggle ? b:save_conceallevel : 0
    else
      let &conceallevel = &conceallevel ? 0 : 2
      let b:save_conceallevel = &conceallevel
    endif
    call rc#ReinforceConcealSyntax()
  endif
  let &lazyredraw = save_lazyredraw
  redraw!
endfunction


" FOCUS-MODE

function rc#ScrollAdjustment()
  let adjustment = (winheight(0) / 2) - rc#CursorRatio()
  if line('.') - adjustment <= adjustment || (line('$') - line('.')) <= (winheight(0) - adjustment)
    return 0
  endif
  return adjustment
endfunction

" Apply focus-mode customizations
function! rc#Focus()
  if !exists('g:limelight_conceal_ctermfg')
   let g:limelight_conceal_ctermfg = 239
  endif
  if exists('g:colors_name')
   let g:save_colors_name = g:colors_name
  endif
  if has('gui_running')
    set fullscreen
  elseif exists('$TMUX')
    silent !tmux set status off
    silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  endif
  augroup VerticallyCenterCursor
    autocmd!
    " Keep cursor/scroll position just north of center
  set lazyredraw
    autocmd VerticallyCenterCursor CursorMoved * exe 'normal zz' . repeat("\<C-e>", rc#ScrollAdjustment())
  augroup END
  let s:save_enableConcealAtCursor = get(g:, 'enableConcealAtCursor', 0)
  let g:enableConcealAtCursor = 1
  let s:save_concealcursor = &concealcursor
  set concealcursor+=n
  let s:save_showtabline = &showtabline
  let &showtabline = 0
  set noshowmode
  set noshowcmd
  set nofoldenable
  Limelight
endfunction

" Revert focus-mode customizations
function! rc#Blur()
  if exists('g:save_colors_name')
   exe 'colorscheme ' . g:colors_name
   unlet g:save_colors_name
  endif
  if has('gui_running')
    set nofullscreen
  elseif exists('$TMUX')
    silent !tmux set status on
    silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  endif
  au! VerticallyCenterCursor CursorMoved
  let g:enableConcealAtCursor = s:save_enableConcealAtCursor
  let &concealcursor = s:save_concealcursor
  let &showtabline = s:save_showtabline
  silent! unlet s:save_showtabline
  set showmode
  set showcmd
  Limelight!
  " Restore User Highlight groups that are being cleared for some reason
  call rc_status#SetDefaultStatusModeHLGroups()
  " Reset filetype to fix concealed syntax highlighting
  exe 'set filetype=' . &filetype
endfunction


" LANGUAGE SUPPORT

function! rc#OnLspBufferEnabled() abort
    let b:lspBufferEnabled = 1
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    highlight LspErrorHighlight term=underline cterm=underline ctermfg=131 gui=underline guifg=#af5f5f
    highlight LspWarningHighlight term=underline cterm=underline ctermfg=11 gui=underline guifg=#ffee33
    highlight LspHintHighlight term=underline cterm=underline gui=underline
    highlight lspReference term=italic cterm=italic gui=italic
	nmap <buffer> <leader>r <plug>(lsp-next-error)
	nmap <buffer> <leader>e <plug>(lsp-previous-error)
	nmap <buffer> <C-n> <plug>(lsp-next-diagnostic)
	nmap <buffer> <C-p> <plug>(lsp-previous-diagnostic)
	nmap <buffer> GR <plug>(lsp-rename)<C-u>
	nmap <buffer> GF <plug>(lsp-references)
	nmap <buffer> GN <plug>(lsp-next-reference)
	nmap <buffer> GP <plug>(lsp-previous-reference)
	nmap <buffer> GD <plug>(lsp-definition)
	nmap <buffer> Gd <plug>(lsp-peek-definition)
	nmap <buffer> GB <plug>(lsp-declaration)
	nmap <buffer> Gb <plug>(lsp-peek-declaration)
	nmap <buffer> GT <plug>(lsp-type-definition)
	nmap <buffer> Gt <plug>(lsp-peek-type-definition)
	nmap <buffer> GI <plug>(lsp-implementation)
	nmap <buffer> Gi <plug>(lsp-peek-implementation)
	nmap <buffer> GH <plug>(lsp-type-hierarchy)
	nmap <buffer> GW <plug>(lsp-workspace-symbol)
	nmap <buffer> GB <plug>(lsp-hover)
	nmap <buffer> GV <plug>(lsp-hover)
	nmap <buffer> GA <plug>(lsp-code-action)
	nmap <buffer> GS <plug>(lsp-status)
    nmap <buffer> GC :let g:lsp_highlight_references_enabled = !g:lsp_highlight_references_enabled<CR>
    nmap <buffer> GE :echo lsp#ui#vim#diagnostics#get_diagnostics_under_cursor()<CR>
endfunction
