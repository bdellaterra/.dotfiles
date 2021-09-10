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
  let isMissingExt = fnamemodify(expand("%"), ":e") == ''
  let isHiddenFile = fnamemodify(expand("%"), ":t") =~ '^\.'
  if a:ext != '' && isMissingExt && !isHiddenFile
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

function! rc#IsAtStartOfLine(mapping)
  let text_before_cursor = getline('.')[0 : col('.')-1]
  let mapping_pattern = '\V' . escape(a:mapping, '\')
  let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
  return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
endfunction

" Helper commands from fzf-vim documentation
function! rc#BuildQuickfixList(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction


" SURROUND

function! rc#SurroundOpenSubs(match)
  let string = a:match
  for [search, replace, flags] in g:surround_open_subs
    let string = substitute(string, search, replace, flags)
  endfor
  return string
endfunction

function! rc#SurroundCloseSubs(match)
  let string = a:match
  let string = substitute(string, '\V{{{\+\v\zs\w+\s*(\{[^}]*\})?', '', 'g') " code snippet
  let string = substitute(string, '\V~~~\+\v\zs\w+\s*(\{[^}]*\})?', '', 'g') " code snippet
  let string = substitute(string, '\V```\+\v\zs\w+\s*(\{[^}]*\})?', '', 'g') " code snippet
  let string = substitute(string, '\V(', ')', 'g')
  let string = substitute(string, '\V[', ']', 'g')
  let string = substitute(string, '\V{', '}', 'g')
  return string
endfunction

function! rc#Surround(...)
  let mode = get(a:000, 0, 0)
  let char = nr2char(getchar())
  let nextChar = ''
  let hasPrompt = [char] == [g:surround_prompt_trigger] || [char] == ['<']
  " Determine action
  if char == g:surround_leader " Double Ctrl-s will swap existing delimiter
    let char = nr2char(getchar())
    let nextChar = nr2char(getchar())
    let hasPrompt = [nextChar] == [g:surround_prompt_trigger]
    let action = [nextChar] == [g:surround_prompt_trigger]
      \ || nextChar =~ '[[:print:]]' ? 'change' : 'delete'
  elseif type(mode) == type(0)
    let action = 'surround'
  else
    let action = mode " 'visual' or 'insert'
  endif
  if hasPrompt || char =~ '[[:print:]]'
    let iNormal = "\<C-\>\<C-n>"
     let iSaveCursor = iNormal . ":let save_cursor = getcurpos()\<CR>"
    let iRestoreCursor = iNormal . ":call setpos('.', save_cursor)\<CR>"
      \ . ([action] == ['surround'] ? "\<Right>" : '')
      \ . ([action] == ['delete'] ? "\<Left>" : '')
    let iRestoreInsert = [mode] == ['insert'] ? 'a' : ''
    let iRestoreSelection = [action] == ['delete']
      \ ? iNormal . "gv\<Left>o\<Left>o"
      \ : 'gv'
    let iRestoreMode = [mode] == ['visual']
      \ ? iRestoreSelection : ([mode] == ['insert']
      \ ? iRestoreInsert : '')
    let iSurround = 'wbviw' . repeat('e', max([mode - 1, 0])) . 'S' . char
    let iChange = 'cs' . char . nextChar
    let iDelete = 'ds' . char
    let iVisual = 'S' . char
    if hasPrompt
      let iSaveCursor = ''
      let iRestoreCursor = ''
      let iRestoreSelection = ''
      let iRestoreMode = ''
    endif
    let cmd = {
      \ 'insert': "\<Plug>Isurround" . char,
      \ 'surround': iSaveCursor . iNormal . iSurround . iRestoreCursor . iRestoreMode,
      \ 'change': iSaveCursor . iNormal . iChange . iRestoreCursor . iRestoreMode,
      \ 'delete': iSaveCursor . iNormal . iDelete . iRestoreCursor . iRestoreMode,
      \ 'visual': iVisual . iRestoreMode,
      \ }
    return cmd[action]
  endif
endfunction


" FOLDING

" Set a nicer foldtext function
" Modified from Edouard, 2008, http://vim.wikia.com/wiki/Customize_text_for_closed_folds
function! rc#FoldText()
  let line = getline(v:foldstart)
  if match( line, '^[ \t]*\(\/\*\|\/\/\)[*/\\]*[ \t]*$' ) == 0
    let initial = substitute( line, '^\([ \t]\)*\(\/\*\|\/\/\)\(.*\)', '\1\2', '' )
    let linenum = v:foldstart + 1
    while linenum < v:foldend
      let line = getline( linenum )
      let comment_content = substitute( line, '^\([ \t\/\*]*\)\(.*\)$', '\2', 'g' )
      if comment_content != ''
	break
      endif
      let linenum = linenum + 1
    endwhile
    let sub = initial . ' ' . comment_content
  else
    let sub = line
    let startbrace = substitute( line, '^.*{[ \t]*$', '{', 'g')
    if startbrace == '{'
      let line = getline(v:foldend)
      let endbrace = substitute( line, '^[ \t]*}\(.*\)$', '}', 'g')
      if endbrace == '}'
	let sub = sub.substitute( line, '^[ \t]*}\(.*\)$', '...}\1', 'g')
      endif
    endif
  endif
  let n = v:foldend - v:foldstart + 1
  let info = " " . n . " lines   "
  let sub = sub . "                                                                                                                  "
  let num_w = getwinvar( 0, '&number' ) * getwinvar( 0, '&numberwidth' )
  let fold_w = getwinvar( 0, '&foldcolumn' )
  let sub = strpart( sub, 0, winwidth(0)
    \ - strlen( info ) - num_w - fold_w - 1 )
  let pad = winwidth(0) - strlen(sub) - strlen(info) - 1
  return sub . repeat(' ', pad) . info
endfunction


" STARTSCREEN

" Show ASCII art + fortune message
function! rc#StartScreen()
  let w = rc#MaxLineWidth()
  let h = winheight(0)
  let margin = 2
  let art = readfile(expand('$HOME') . '/.vim/art.txt')
  let toASCII = 'iconv -f utf-8 -t ascii//translit'
  let trim = "awk '{$1=$1;print}'"
  let fortune = systemlist('fortune | ' .  toASCII . ' | ' . trim)
  let artWidth = min(map(copy(art), 'len(v:val)'))
  let lineWidth = max(map(copy(fortune), 'len(v:val)'))
  let formatWidth = w - artWidth - margin * 2
  if lineWidth > formatWidth
    let fortune = systemlist('fmt --width ' . formatWidth, fortune)
    let lineWidth = max(map(copy(fortune), 'len(v:val)'))
  endif
  exe ':normal' . max([1, h - len(art) - 1]) . 'O'
  call append(line('.'), art)
  normal gg
  let lnum = (margin / 2) " leaving space at top
  for line in fortune
    let lnum += 1
    let cur = getline(lnum)
    let pad = w - len(cur) - (lineWidth - len(line)) - (margin * 2)
    call setline(lnum, cur . printf('%' . pad . 'S', line))
  endfor
  normal gg
  redraw!
  nnoremap <buffer> <silent> <Return> :enew<CR>:call startscreen#start()<CR>
endfunction


" BUFFERS

" Move forward/backward in the list of Most Recently Used files
function! rc#JumpMRU(...)
  if !exists('g:mruFiles') | let g:mruFiles = [] | endif
  let delta = get(a:000, 0, -1)
  if len(g:mruFiles) == 0
    let g:mruFiles = get(a:000, 1, filter(MruGetFiles(), 'filereadable(v:val)'))
    let g:mruIndex = 0
    let g:mruBase = ProjectRootGuess()
  endif
  if len(g:mruFiles) > 0
    let g:mruIndex -= delta
    if g:mruIndex > len(g:mruFiles)
      let g:mruIndex = 0
    endif
    if g:mruIndex < 0
      let g:mruIndex = len(g:mruFiles) - 1
    endif
    let g:mruFile = g:mruFiles[g:mruIndex]
    silent! exe 'silent! edit ' .  fnamemodify(g:mruFiles[g:mruIndex], ':p')
  endif
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
    let mruFiles = MruGetFiles()
    if len(mruFiles) > 1
      exe 'edit ' . MruGetFiles()[1]
    endif
  else
    confirm buffer #
  endif
endfunction


" CLIPBOARD

" Share yanked text with system clipboard, even when Vim lacks 'clipboard' support
function rc#CopyToClipboard(text, ...)
  let register = get(a:000, 0, '')
  if !has('clipboard')
    if exists('g:clipCopy') && register == ''
      call system(g:clipCopy, a:text)
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
  if exists('g:clipPaste')
    let @" = system(g:clipPaste)
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

function rc#AddDefaultTitle()
  let title = fnamemodify(expand('%'), ':t:r')
  call append(0, ['', title, repeat('=', len(title)), ''])
  set filetype=pandoc
endfunction

function rc#AutoAddMarkdownToNotes()
  let g:nv_glob_paths = join(map(copy(g:nv_search_paths), 'v:val . "/[^.]*/*"'), ',')
  augroup MarkdownNotes
    au!
    exe 'autocmd BufEnter ' . g:nv_glob_paths . ' if &ft=="" | edit | endif'
    exe 'autocmd BufRead ' . g:nv_glob_paths . ' if readfile(expand("%")) == [] | call rc#AddDefaultTitle() | endif'
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
  if &conceallevel == 0
    normal zz
    let midpoint = winheight(0) / 2
    let posFromCenter = winline() - midpoint
    let currentLine = line('.')
    let lastLine = line('$')
    let targetFromTop = rc#CursorRatio()
    let adjustment = midpoint - targetFromTop
    if currentLine > targetFromTop && currentLine < lastLine - targetFromTop && posFromCenter <= adjustment
      let correctedAdjustment = abs(adjustment + posFromCenter)
      if adjustment > 0
        exe 'normal! ' . correctedAdjustment . "\<C-e>"
      endif
      if adjustment < 0
        exe 'normal! ' . correctedAdjustment . "\<C-y>"
      endif
    endif
  endif
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
    autocmd VerticallyCenterCursor CursorMoved * call rc#ScrollAdjustment()
  augroup END
  " use simpler smooth-scroll if conceal syntax is on
  let s:save_scrolloff = &scrolloff
  if &conceallevel > 0
    let &scrolloff = 100
  endif
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
  let &scrolloff = s:save_scrolloff
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


" PLUGINS

" Support loading plugin/options from file w/ empty lines and comments removed
function rc#Plugin(plug)
  let [locator, options] = matchlist(a:plug, '\v^([^# ]*)\s*([{(].*[)}])?')[1:2]
  if len(locator)
    call call('plug#', len(options) ? [locator, eval(options)] : [locator])
  end
endfunction

