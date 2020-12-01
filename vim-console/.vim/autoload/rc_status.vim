
if &cp || exists("g:loaded_rc_status_plugin")
 finish
endif
let g:loaded_rc_status_plugin = "v01"
let s:keepcpo        = &cpo
set cpo&vim

" Set highlight groups used in statusline
function rc_status#SetDefaultStatusModeHLGroups()
  highlight User1 ctermfg=233 ctermbg=6
  highlight User2 ctermfg=233 ctermbg=14
  highlight User3 ctermfg=233 ctermbg=9
  highlight User4 ctermfg=233 ctermbg=8
  highlight User5 ctermfg=233 ctermbg=1
  highlight User6 ctermfg=233 ctermbg=11
endfunction

" Set statusline highlight based on current mode
function! rc_status#StatusModeHL()
  let mode = mode()
  " User4 highlight for Insert/Replace mode
  " User3 Highlight when changing a readonly file
  if mode =~ '\vi|R' " '=~#' to match case
    return &readonly ? '%3*' : '%4*'
  " User2 highlight when in Visual mode
  elseif mode =~ '\vv|s|'
    return '%2*'
  endif
  " User6 if over concealed syntax
  if rc#IsCursorOverConcealed()
    return '%6*'
  endif
  " User1 highlight for Normal mode
  return '%1*'
endfunction

" Generate unicode bar to represent progress through file
let s:percentBars = ['█', '▇', '▆', '▅', '▄', '▃', '▂', '▁']
function rc_status#StatusPercentBar()
  let percent = (1.0 * line('.')) / line('$')
  let index = float2nr(round((len(s:percentBars) - 1) * percent))
  return s:percentBars[index]
endfunction

" Toggle between more and less verbose variations of statusline
function rc_status#ToggleVerboseStatus()
  if !exists('s:verboseStatus') || !s:verboseStatus
    let s:verboseStatus = 1
  else
    let s:verboseStatus = 0
  endif
endfunction

" Generate custom statusline (Ctrl-S omitted as it halts terminal)
let s:statusWidth = 80
let s:statusModeSymbols = {
  \ 'n':'ƞ', 'v':'ⱱ', 'V':'Ⅴ', '':'⋎', 's':'ș', 'S':'Ṣ',
  \ 'i':'∣', 'R':'Ɍ', 'c':'ċ', 'r':'ṙ', '!':'⟳', 't':'ẗ'
  \ }
function rc_status#Status()
  try
    let verbose = exists('s:verboseStatus') && s:verboseStatus
    let bufnum = '%2.n'
    let corner = rc_status#StatusModeHL()
      \ . (verbose ? bufnum : '  ')
      \ . '%*'
    let line = &number && !verbose ? '' : '%5l'
    let col = '%3c'
    let pos = line != '' ? line . ' ' . col : col
    let mod = '%{&modified ? "…" : ""}'
    let ro = '%{&modifiable && &readonly ? "" : " "}'
    let file = ro . (verbose ? '%f' : '%t') . mod
    let branch = verbose ? '%{&buftype == "" ? " ｢" . FugitiveHead() . "｣ " : ""}' : ''
    let mode = verbose ? get(s:statusModeSymbols, mode(), '') : ''
    let conceal = verbose ? '%{&conceallevel ? "␦" : ""}' : ''
    let paste = '%{&paste ? "⎘" : ""}'
    let modeInfo = mode . conceal . paste
    let pb = '%{rc_status#StatusPercentBar()}'
    let datetime = verbose ? ' ' . strftime('%d/%b %H:%M') . ' ' : ''

    " file meta
    let ff = &fileformat
    let fe = &fileencoding != "" ? "/" . &fileencoding : ""
    let ft = &filetype != "" ? "/" . &filetype : "/unknown"
    let bomb = &bomb ? "※" : ""
    let g:statusLineFileInfo = verbose ? ff . fe . ft . bomb . '  ⋰⋰' : ''

    let leftSide = ' %<' . file . branch 
    let rightMinWidth = string(rc#MaxLineWidth() - s:statusWidth)
    let rightSide = datetime . ' ' . modeInfo . '  '
      \ . '%{&buftype == "terminal" ? g:os : g:statusLineFileInfo}' . pos . '  ' . pb
    let g:statusline = corner . leftSide . ' %= '
      \ . '%#TabLine# ' . rightSide
    return g:statusline
  catch
    return v:exception
  endtry
endfunction
