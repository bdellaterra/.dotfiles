" *** Inital Configuration ****************************************************

" PLUGIN MANAGER

" Auto-install plug.vim
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" HELPER FUNCTIONS

" Support loading plugin/options from file w/ empty lines and comments removed
function s:Plugin(plug)
  let [locator, options] = matchlist(a:plug, '\v^([^# ]*)\s*(\{[^}#]*\})?')[1:2]
  if len(locator)
    call call('plug#', len(options) ? [locator, eval(options)] : [locator])
  end
endfunction

" Convert path to forward slashes with a slash at the end
function s:DirSlashes(path)
  return substitute(a:path, '[^/\\]\@<=$\|\\', '/', 'g')
endfunction

" Create directory if necessary and normalize slashes
function s:MakeDir(path)
  try
    if !isdirectory(a:path) && exists('*mkdir')
      call mkdir(a:path, 'p')
    endif
  endtry
  return s:DirSlashes(a:path)
endfunction

" Overload behavior of the equals key
function s:EditBufferOrReindent(...)
  let bufNum = get(a:000, 0, '')
  if bufNum == ''
    return "="
  elseif bufNum == 0
    return ":\<C-u>confirm buffer #\<CR>"
  else
    return ":\<C-u>confirm buffer" . bufNum . "\<CR>"
  endif
  return ""
endfunction

" Toggle between conceallevel 0 and 2. Pass optional boolean
" to disable temporarily (false) or restore last on/off setting (true)
augroup ToggleConceal
  autocmd!
  autocmd FileType * call <SID>ReinforceConcealSyntax()
augroup END
function s:ReinforceConcealSyntax()
  if &conceallevel
    silent! exe 'source ~/.dotfiles/vim-console/.vim/after/syntax/' . &filetype . '.vim'
  endif
endfunction
function ToggleConceal(...)
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
    call <SID>ReinforceConcealSyntax()
  endif
endfunction

" Get full file path for current buffer or # buffer if command-count provided
function s:BufferFile(...)
  let fnameMods = get(a:000, 0, '')
  return expand((v:count ? '#'.v:count : '%') . ':p' . fnameMods)
endfunction

" Share yanked text with system clipboard when Vim lacks 'clipboard' support
if executable('xclip')
  let s:clipCopy = 'xclip' " nix
endif
if executable('pbcopy')
  let s:clipCopy = 'pbcopy' " mac
endif
" Symlink windows executables to ~/bin path under Windows Subsystem for Linux
if executable('clip')
 " Default (with no paste support) at /mnt/c/Windows/System32/clip.exe
  let s:clipCopy = 'clip'
endif
if executable('win32yank') && executable('unix2dos')
  " Install from https://github.com/equalsraf/win32yank/releases
  let s:clipCopy = 'unix2dos | win32yank -i'
endif
function s:CopyToClipboard(text, ...)
  let register = get(a:000, 0, '')
  if exists('s:clipCopy') && register == ''
    call system(s:clipCopy, a:text)
  endif
endfunction

" Share clipboard text with paste buffer when Vim lacks 'clipboard' support
if executable('xclip')
  let s:clipPaste = 'xclip -o' " nix
endif
if executable('pbcopy')
  let s:clipPaste = 'pbpaste' " mac
endif
" Symlink windows executables to ~/bin path under Windows Subsystem for Linux
if executable('win32yank') && executable('unix2dos')
  " Install from https://github.com/equalsraf/win32yank/releases
  let s:clipPaste = 'win32yank -o | dos2unix'
endif
function s:PasteFromClipboard()
  if exists('s:clipPaste')
    let @" = system(s:clipPaste)
  endif
endfunction


let g:surround_open_subs = []
function! SurroundOpenSubs(match)
  let string = a:match
  for [search, replace, flags] in g:surround_open_subs
    let string = substitute(string, search, replace, flags)
  endfor
  return string
endfunction

let g:surround_close_subs = [
  \ [ '\V{{{\w\+', '}}}', 'g' ], 
  \ [ '\V(', ')', 'g' ], 
  \ [ '\V[', ']', 'g' ], 
  \ [ '\V{', '}', 'g' ], 
  \ ]
function! SurroundCloseSubs(match)
  let string = a:match
  let string = substitute(string, '\V{{{\+\v\zs\w+\s*(\{[^}]*\})?', '', 'g') " code snippet
  let string = substitute(string, '\V~~~\+\v\zs\w+\s*(\{[^}]*\})?', '', 'g') " code snippet
  let string = substitute(string, '\V```\+\v\zs\w+\s*(\{[^}]*\})?', '', 'g') " code snippet
  let string = substitute(string, '\V(', ')', 'g')
  let string = substitute(string, '\V[', ']', 'g')
  let string = substitute(string, '\V{', '}', 'g')
  return string
endfunction

" Surround text with delimiter. Optional "mode" param indicates 'visual'
" selection or a command-count for number of words to surround w/ delimiter
let g:surround_leader = "\<C-s>"
let g:surround_prompt_trigger = "\<C-e>"
let g:surround_{char2nr(g:surround_prompt_trigger)} = "\1Enter string: "
  \ . "\r.*\r\\=SurroundOpenSubs(submatch(0))\1\r\1\r.*\r\\=SurroundCloseSubs(submatch(0))\1"
function! s:Surround(...)
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

exe 'map <expr>  ' . g:surround_leader . ' <SID>Surround(v:count)'
exe 'imap <expr> ' . g:surround_leader . ' <SID>Surround("insert")'
exe 'vmap <expr> ' . g:surround_leader . ' <SID>Surround("visual")'

" Show syntax group and translated syntax group of character under cursor
" From Laurence Gonsalves, 2016, https://stackoverflow.com/questions/9464844/how-to-get-group-name-of-highlighting-under-cursor-in-vim
function! s:SynGroup()
  let l:s = synID(line('.'), col('.'), 1)
  echo synIDattr(l:s, 'name') . ' ->  ' . synIDattr(synIDtrans(l:s), 'name')
endfunction

" Set a nicer foldtext function
" (Modified) From Edouard, 2008, http://vim.wikia.com/wiki/Customize_text_for_closed_folds
function! MyFoldText()
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
  return sub . info
endfunction

" Calculate ideal position for cursor to settle during scrolling
function! s:CursorRatio()
  return float2nr(round(winheight(0) * 0.381966))
endfunction

" Apply focus-mode customizations
function! s:Focus()
  if has('gui_running')
    set fullscreen
  elseif exists('$TMUX')
    silent !tmux set status off
    silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  endif
  augroup VerticallyCenterCursor
    autocmd!
    " Keep cursor/scroll position just north of center
    autocmd VerticallyCenterCursor CursorMoved * exe 'normal zz'
      \ . repeat("\<C-e>", (winheight(0) / 2) - <SID>CursorRatio())
  augroup END
  let s:save_showtabline = &showtabline
  let &showtabline = 0
  set noshowmode
  set noshowcmd
  Limelight
endfunction

" Revert focus-mode customizations
function! s:Blur()
  if has('gui_running')
    set nofullscreen
  elseif exists('$TMUX')
    silent !tmux set status on
    silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  endif
  au! VerticallyCenterCursor CursorMoved
  let &showtabline = s:save_showtabline
  unlet s:save_showtabline
  set showmode
  set showcmd
  Limelight!
  " Restore User Highlight groups that are being cleared for some reason
  call SetDefaultStatusModeHLGroups()
endfunction

" Check whether the sign column is active
function s:IsSignColumnActive()
  return &signcolumn == 'yes'
    \ || &signcolumn == 'auto' && len(sign_getplaced())
endfunction

" Determine maximum line width accounting for left-side gutters
function s:MaxLineWidth()
  return winwidth(0)
    \ - (s:IsSignColumnActive() ? 2 : 0)
    \ - (&number ? len(line('$')) + 1 : 0)
endfunction

" Set highlight groups used in statusline
function SetDefaultStatusModeHLGroups()
  highlight User1 ctermfg=233 ctermbg=145
  highlight User2 ctermfg=233 ctermbg=11
  highlight User3 ctermfg=233 ctermbg=231
  highlight User4 ctermfg=233 ctermbg=88
  highlight User5 ctermfg=233 ctermbg=123
endfunction

" Set statusline highlight based on current mode
function! s:StatusModeHL()
  let mode = mode()
  " User4 highlight for Insert/Replace mode
  " User3 Highlight when changing a readonly file
  if mode =~ '\vi|R' " '=~#' to match case
    return &readonly ? '%4*' : '%3*'
  " User2 highlight when in Visual mode
  elseif mode =~ '\vv|s|'
    return '%2*'
  endif
  " User1 highlight for Normal mode
  " User5 for non-modifiable bufffers
  return !&modifiable ? '%5*' : '%1*'
endfunction

" Generate unicode bar to represent progress through file
let s:percentBars = ['█', '▇', '▆', '▅', '▄', '▃', '▂', '▁']
function s:StatusPercentBar()
  let percent = (1.0 * line('.')) / line('$')
  let index = float2nr(round((len(s:percentBars) - 1) * percent))
  return s:percentBars[index]
endfunction

" Toggle between more and less verbose variations of statusline
function s:ToggleVerboseStatus()
  if !exists('s:verboseStatus') || !s:verboseStatus
    let s:verboseStatus = 1
  else
    let s:verboseStatus = 0
  endif
endfunction

" Generate custom statusline (Ctrl-S omitted as it halts terminal)
let s:statusWidth = 80
let s:statusModeSymbols = {
  \ 'n':'ƞ', 'v':'ⱱ', 'V':'Ṿ', '':'ṽ', 's':'ș', 'S':'Ṣ',
  \ 'i':'ί', 'R':'Ɍ', 'c':'ċ', 'r':'ṙ', '!':'⟳', 't':'ẗ'
  \ }
function MyStatus()
  try
    let verbose = exists('s:verboseStatus') && s:verboseStatus
    let bufnum = '%2.n'
    let corner = s:StatusModeHL()
      \ . (verbose ? bufnum : '  ')
      \ . '%#StatusLine#'
    let line = &number && !verbose ? '' : printf('%5d', line('.'))
    let col = printf('%3d', col('.'))
    let pos = line != '' ? line . ' ' . col : col
    let mod = &modified ? '…' : ''
    let ro = &modifiable && &readonly ? '' : ''
    let ff = &fileformat != '' ? &fileformat : ''
    let fe = &fileencoding != '' ? '/' . &fileencoding : ''
    let ft = &filetype != '' ? '/' . &filetype : 'unknown'
    let bomb = &bomb ? '※' : ''
    let file = (verbose ? '%F' : '%t')
      \ . (mod != '' ? mod : ' ')
      \ . (ro != '' ? ' ' . ro : '')
    let datetime = strftime('%e %b %Y %l:%M%P')
    let mode = verbose ? get(s:statusModeSymbols, mode(), '') : ''
    let conceal = verbose && &conceallevel ? '␦' : ''
    let paste = &paste ? '⎘' : '' " ⎀ϊǐ
    let modeInfo = mode . conceal . paste
    let fileInfo = verbose ? ff . fe . ft . bomb : ''
    let pb = s:StatusPercentBar()
    let leftSide = ' %<' . ' ' . file
    let rightMinWidth = string(s:MaxLineWidth() - s:statusWidth)
    let rightSide = modeInfo . '  ' . fileInfo . ' ' . pos . '  ' . pb
    return corner . leftSide . ' %= '
      \ . '%#TabLine#%' . rightMinWidth  . '(' . rightSide . '%)'
  catch
    return v:exception
  endtry
endfunction

" Show ASCII art + fortune message
function! s:StartScreen()
  let w = s:MaxLineWidth()
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


" *** General Configuration ***************************************************

" VIM SETTINGS

" Disable backwards-compatibility with Vi (ancestor of Vim)
set nocompatible
set cpoptions&vim

" Specify the mapleader for Vim mappings
let mapleader = ','

" Disable modelines for better security
set modelines=0

" Allow backspacing over everything
set backspace=indent,eol,start

" Set minimum lines of context to display around cursor
set scrolloff=5

" Display most of a last line that doesn't fit in the window
set display=lastline

" Auto-save when opening/changing buffers
set autowriteall

" Set directory where temporary files can be stored
let s:TmpDir = s:MakeDir($HOME . '/tmp/vim')

" Keep swap/backup/undo files from cluttering the working directory
set nobackup
exe 'set directory=' . s:TmpDir
set undofile
exe 'set undodir=' . s:TmpDir

" Disable beep and visual flash alerts
autocmd VimEnter * set vb t_vb=

" Clear the screen so there are no initial status messages
autocmd VimEnter * silent! redraw!

" Don't automatically wrap lines
set formatoptions-=t

" Ignore case in searches using only lowercase letters
set ignorecase smartcase

" Keep a long command history
set history=100

" Initial fold regions based on syntax-rules
set foldmethod=syntax

" Have all folds open when a new file is loaded
set foldlevelstart=999

" Automatically open folds in insert-mode
set foldopen=all

" Prevent "Hit enter to continue" message
set shortmess+=T
" Further reduce prompts by increasing the height of the command line
set cmdheight=1

" Set default tabbing behavior
set shiftwidth=2
set tabstop=4
set expandtab

" Allow cursor over EOL
set ve=onemore

" Always show status line
set laststatus=2

" Use modern encoding
set encoding=utf8

" show file diffs using vertical splits
set diffopt+=vertical

" Automatically read file changes
set autoread
" Autoread depends on file status being checked. This speeds that up
autocmd InsertEnter,CursorMoved,CursorMovedI,CursorHold,CursorHoldI * checktime

" Faster updates
set updatetime=1000

" Reduce timeout for operator-pending mode
set timeout timeoutlen=500 ttimeoutlen=500


" GUI

" Don't show the toolbar/icons
set guioptions-=T


" TERMINAL

" Fix arrow keys
if &term =~ '^screen' || has('Mac')
  " From Chris Johnsen, 2012, https://unix.stackexchange.com/questions/29907/how-to-get-vim-to-work-with-tmux-properly
  execute "set <xUp>=\e[1;*A"
  execute "set <xDown>=\e[1;*B"
  execute "set <xRight>=\e[1;*C"
  execute "set <xLeft>=\e[1;*D"
  " From romainl, 2012, https://stackoverflow.com/questions/8813855/in-vim-how-can-i-make-esc-and-arrow-keys-work-in-insert-mode
  nnoremap <Esc>A <up>
  nnoremap <Esc>B <down>
  nnoremap <Esc>C <right>
  nnoremap <Esc>D <left>
  inoremap <Esc>A <up>
  inoremap <Esc>B <down>
  inoremap <Esc>C <right>
  inoremap <Esc>D <left>
endif

" Modal cursor in terminal/tmux
" From avivr, 2015, https://vi.stackexchange.com/questions/3379/cursor-shape-under-vim-tmux
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
else
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[2 q"
endif

" Enable mouse if supported
if has('mouse')
  set mouse=a
  if &term =~ '^screen' && has('mouse_xterm')
    set ttymouse=xterm2
  endif
endif

" Improve console colors
if $TERM =~ '256color' || $COLORTERM == 'gnome-terminal'
  set t_Co=256
endif


" FILE MANAGER

" Replace default file manager when viewing directories
let g:ranger_replace_netrw = 1

" Set temp file location
let g:ranger_choice_file = s:TmpDir . 'RangerChosenFile'

" Don't use plugin mappings
let g:ranger_map_keys = 0

" ',.' will browse files at current buffer's directory
map <leader>. :Ranger<CR>

" ',f' will browse files at working-directory (usually project root)
map <leader>f :RangerWorkingDirectory<CR>


" CLIPBOARD

" Share system clipboard with unnamed register for copy/paste
if has('clipboard')
  set clipboard=unnamed,unnamedplus
else
  autocmd TextYankPost * :call <SID>CopyToClipboard(v:event.regcontents, v:event.regname)
  autocmd FocusGained * :call <SID>PasteFromClipboard()
endif

" 'F12' will toggle paste mode, which disables auto-formatting of copy/pasted text
noremap <F12> :set paste! paste?<CR>
imap <expr> <F12> set paste! paste? ? '' : ''


" SELCTION

" In input mode, Ctrl + movement keys initiate visual selection
inoremap <C-Left>  <C-\><C-n>v
inoremap <C-h>     <C-\><C-n>v
inoremap <expr> <C-Down>   "\<C-o>v\<Down>\<Left>"
inoremap <expr> <C-j>   "\<C-o>v\<Down>\<Left>"
inoremap <expr> <C-Up>   "\<C-\>\<C-n>v\<Up>" . (col('.')>1?"\<Right>":"")
inoremap <expr> <C-k>   "\<C-\>\<C-n>v\<Up>" . (col('.')>1?"\<Right>":"")
inoremap <C-Right> <C-o>v
inoremap <C-l>     <C-o>v


" MOVEMENT

" '}' will jump down to start of next paragraph, not blank line before
noremap } }}{<Enter>

" '{' will jump up to start of paragraph, not blank line before
noremap { {{<Enter>


" SCROLLING

" lock cursor to optimal location while scrolling
map <expr> <ScrollWheelUp> winline() >= <SID>CursorRatio() ? "\<C-e>gj" : 'gj'
map <expr> <ScrollWheelDown> winline() <= <SID>CursorRatio() ? "\<C-y>gk" : 'gk'


" WINDOWS

" Save current buffer when leaving Vim for another Tmux pane
let g:tmux_navigator_save_on_switch = 1

" Don't leave Vim while it's in a zoomed Tmux pane
let g:tmux_navigator_disable_when_zoomed = 1

" In normal mode, Ctrl + movement keys to switch windows w/ Tmux awareness
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-Left>  :TmuxNavigateLeft<CR>
nnoremap <silent> <C-h>     :TmuxNavigateLeft<CR>
nnoremap <silent> <C-Down>  :TmuxNavigateDown<CR>
nnoremap <silent> <C-j>     :TmuxNavigateDown<CR>
nnoremap <silent> <C-Up>    :TmuxNavigateUp<CR>
nnoremap <silent> <C-k>     :TmuxNavigateUp<CR>
nnoremap <silent> <C-Right> :TmuxNavigateRight<CR>
nnoremap <silent> <C-l>     :TmuxNavigateRight<CR>

" In normal mode, Ctrl-w + window-movement to open window in that direction
nnoremap <silent> <C-w><C-Left>  :vertical aboveleft new<CR>
nnoremap <silent> <C-w><C-h>     :vertical aboveleft new<CR>
nnoremap <silent> <C-w><C-Down>  :belowright new<CR>
nnoremap <silent> <C-w><C-j>     :belowright new<CR>
nnoremap <silent> <C-w><C-Up>    :aboveleft new<CR>
nnoremap <silent> <C-w><C-k>     :aboveleft new<CR>
nnoremap <silent> <C-w><C-Right> :vertical belowright new<CR>
nnoremap <silent> <C-w><C-l>     :vertical belowright new<CR>
" Release Ctrl key before movement to open full-width/full-height window
nnoremap <silent> <C-w><Left>    :vertical topleft new<CR>
nnoremap <silent> <C-w>h         :vertical topleft new<CR>
nnoremap <silent> <C-w><Down>    :botright new<CR>
nnoremap <silent> <C-w>j         :botright new<CR>
nnoremap <silent> <C-w><Up>      :topleft new<CR>
nnoremap <silent> <C-w>k         :topleft new<CR>
nnoremap <silent> <C-w><Right>   :vertical botright new<CR>
nnoremap <silent> <C-w>l         :vertical botright new<CR>
" Use Shift key with movement to move window in that direction
nnoremap <silent> <C-w><S-Left>  <C-w>H
nnoremap <silent> <C-w><S-Down>  <C-w>J
nnoremap <silent> <C-w><S-Up>    <C-w>K
nnoremap <silent> <C-w><S-Right> <C-w>L

" 'Ctrl+w,Enter' will toggle zooming the current window
map <silent> <C-w><Enter> :silent! call ZoomWin()<CR>


" BUFFERS

" If used after a numeric count the equals key switches to that number buffer.
" Number zero signifies the alternate buffer. (See :help alternate-file)
" Otherwise the default re-indent behavior is used.
noremap <expr>= <SID>EditBufferOrReindent(v:count)
noremap 0= :<C-u>confirm buffer #<CR>  " Vim won't pass zero-counts to mappings

" '-=' will delete current buffer or # buffer number from command-count
nnoremap -= :<C-u>exe (v:count ? v:count : '') . 'bdelete'<CR>
nnoremap 0-= :<C-u>confirm bdelete #<CR>
" Alias 'Ctrl-w,Ctrl-w'
nmap <C-w><C-w> -=
nmap 0<C-w><C-w> 0-=

" '+=' will prompt for editing a file with filename needing to be specified.
" Path will be same as the current buffer or that of # buffer from command-count
nnoremap += :<C-u>edit <C-r>=<SID>BufferFile(':h') . '/'<CR>

" '=]' will switch to previous buffer, or command-count buffers back
nnoremap =] :<C-u>exe (v:count ? v:count : '') . 'bnext'<CR>
" Alias 'Tab'
nmap <Tab> =]

" '=[' will switch to previous buffer, or command-count buffers back
nnoremap =[ :<C-u>exe (v:count ? v:count : '') . 'bprev'<CR>
" Alias 'Shift-Tab'
nmap <S-Tab> =[

" '=,Backspace' will display active buffers for selection/search
nnoremap =/ :Buffers<CR>
" '=<Backspace>' will list buffers with fullscreen display
nnoremap =<Backspace> :Buffers!<CR>

" No editing directories (buggy integration with ranger plugin)
autocmd BufEnter * if isdirectory(expand("%")) | silent! bwipeout! | endif


" INDENTATION

" for efficiency, don't auto-detect indentation settings
let g:sleuth_automatic = 0


" ALIGNMENT

" ',a' wil start interactive EasyAlign in visual mode (e.g. vip,a)
xmap <leader>a <Plug>(EasyAlign)

" ',a' will start interactive EasyAlign for a motion/text object (e.g. ,aip)
nmap <leader>a <Plug>(EasyAlign)"


" COMPLETION

" Show completion menu even if it has one item
set completeopt+=menuone

" Do not auto-select completion option
set completeopt+=noselect

" Shut off completion messages and beeps
set shortmess+=c
set belloff+=ctrlg

" Show auto-complete menu without hitting <Tab>
let g:mucomplete#enable_auto_at_startup = 1

" Complete filenames relative to open buffer if './' is used to begin the path
" <Tab> must be used to trigger this. Not applied for automatic-completion
function! s:CompleteWithRelativeFilePaths()
  let g:mucomplete#buffer_relative_paths = 0
  .g:'\.[/\\]\([^/\\]*[/\\]\?\)*\%#:let g:mucomplete#buffer_relative_paths = 1
  return "\<plug>(MyFwd)"
endfunction
imap <plug>(MyFwd) <plug>(MUcompleteFwd)
imap <expr> <silent> <tab> <SID>CompleteWithRelativeFilePaths()


" SNIPPETS

" Directory where personal snippets are stored
let g:UltiSnipsSnippetsDir = '~/.vim-personal/after/UltiSnips'

" Define triggers
let g:UltiSnipsExpandTrigger = "<M-Enter>"
let g:UltiSnipsListSnippets = "<M-l>"
let g:UltiSnipsJumpForwardTrigger  = "<M-Enter>"
let g:UltiSnipsJumpBackwardTrigger = "<M-l>"

" Automatically activate file type skeletons
let skeletons#autoRegister = 1

" Set directory where skeletons are stored
let skeletons#skeletonsDir = '~/.skeletons/vim'


" FUZZY-FIND

" match FZF colors to the current color scheme
let g:fzf_colors = {
  \ 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment']
  \ }

" Helper commands taken directly from fzf-vim documentation
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_colors = {
  \ 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment']
  \ }

command! -bang -nargs=* GGrep
      \ call fzf#vim#grep(
      \   'git grep --line-number '.shellescape(<q-args>), 0,
      \   { 'dir': systemlist('git rev-parse --show-toplevel')[0] }, <bang>0)

command! -bang Colors
      \ call fzf#vim#colors({'left': '15%', 'options': '--reverse --margin 30%,0'}, <bang>0)

command! -bang -nargs=* Ag
      \ call fzf#vim#ag(<q-args>,
      \                 <bang>0 ? fzf#vim#with_preview('up:60%')
      \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
      \                 <bang>0)

command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
      \   <bang>0 ? fzf#vim#with_preview('up:60%')
      \           : fzf#vim#with_preview('right:50%:hidden', '?'),
      \   <bang>0)

command! -bang -nargs=? -complete=dir Files
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

" Temporarily switch FZFMru to search relative to current directory
function s:FZFRelativeMru()
  let save_rel = g:fzf_mru_relative
  let g:fzf_mru_relative = 1
  FZFMru
  let g:fzf_mru_relative = save_rel
endfunction
command! -bang -nargs=* FZFRelativeMru call <SID>FZFRelativeMru()

" FZF mappings are all prefixed with ',/'
map <leader>/<space>   :Files 
map <leader>/~   :Files ~<CR>
map <leader>/.   :<C-u>Files <C-r>=<SID>BufferFile(':h') . '/'<CR><CR>
map <leader>/=   :Buffers<CR>
map <leader>/3   :Colors<CR> " '#' for color-code
map <leader>/o   :Lines<CR> " 'o' for "open" buffer lines
map <leader>/b   :BLines<CR> " 'b' for "buffer" lines
map <leader>/t   :Tags<CR>
map <leader>/f   :BTags<CR> " 'f' for current "file"
map <leader>/'   :Marks<CR>
map <leader>/`   :Marks<CR>
map <leader>/W   :Windows<CR>
map <leader>/L   :Locate
map <leader>/h   :History<CR>
map <leader>/:   :History:<CR>
map <leader>//   :History/<CR>
map <leader>/s   :Snippets<CR>
map <leader>/C   :Commands<CR>
map <leader>/M   :Maps<CR>
map <leader>/?   :Helptags<CR>
map <leader>/w   :GFiles<CR> " 'w' for "watched" files
map <leader>/d   :GFiles?<CR> " 'd' for "diff"
map <leader>/m   :FZFMru<CR> " 'm' for "most recent"
" Requires ProjectRoot plugin
map <leader>/p   :exe 'Files ' . ProjectRootGuess()<CR>
map <leader>/l   :FZFRelativeMru<CR> " 'l' for "latest"
  \ :let g:fzf_mru_relative
" Requires Fugitive plugin
map <leader>/c   :Commits!<CR>
map <leader>/v   :BCommits!<CR> " 'v' for 'versions'
" Requires git
if executable('git')
  map <leader>/g   :GGrep<CR>
  map <leader>/G   :GGrep!<CR>
  map <leader>/<leader> :GGrep<CR> " convenience mapping
endif
" Requires https://github.com/ggreer/the_silver_searcher
if executable('ag')
  map <leader>/a   :Ag<CR>
  map <leader>/A   :Ag!<CR>
  map <leader>/<leader> :Ag!<CR> " convenience mapping
endif
" Requires https://github.com/BurntSushi/ripgrep
if executable('rg')
  map <leader>/r   :Rg<CR>
  map <leader>/R   :Rg!<CR>
  map <leader>/<leader> :Rg!<CR> " convenience mapping
endif

" 'Ctrl-a' prefix will setup the following custom mappings in FZF window
" (Hit 'Ctrl-a' twice if using Tmux and Tmux prefix is also 'Ctrl-a')
let g:fzf_action = {
  \ 'Ctrl-t': 'tab split',
  \ 'Ctrl-x': 'split',
  \ 'Ctrl-v': 'vsplit' }


" LINTING

" Set signs for sign column
let g:ale_sign_warning = '•'
let g:ale_sign_error = '▶'

" Set highlight groups for signs
highlight link ALEWarningSign SignColumn
highlight link ALEErrorSign WarningMsg
highlight link ALEError WarningMsg

" Always keep sign column open
let g:ale_sign_column_always = 1

" ',Enter' will auto-fix linter errors (without saving)
map <leader><Enter> :ALEFix \| silent! %foldopen!<CR> " unclear why ALEFix closes folds

" ',k' will toggle spell-check highlighting
map <leader>k :set spell! spell?<CR>


" VERSION CONTROL

" Git mappings are all prefixed with ',g'
map <leader>g<Space> :Git<Space>
map <leader>gwd :Gcd<Space>
map <leader>gr  :Gread<CR>
map <leader>gw  :Gwrite!<CR>
map <leader>gg  :Gwrite! \| Gcommit<CR>
map <leader>gs  :Gstatus<CR>
map <leader>gc  :Gcommit<CR>
map <leader>ga  :Gcommit --amend<CR>
map <leader>g/  :Ggrep<Space>
map <leader>gl  :Glog --graph --decorate --date=short<CR>
map <leader>ge  :Gedit<Space>
map <leader>gh  :Gsplit<Space>
map <leader>gv  :Gvsplit<Space>
map <leader>gd  :Gvdiff<CR>
map <leader>gx  :Gdelete<CR>
map <leader>gX  :Gdelete!<CR>
map <leader>gt  :Twiggy<CR>
map <leader>gb  :Gblame<CR>
map <leader>gq  :Gwq<CR>
map <leader>g<Enter> :Gbrowse<CR>

" Use `gl` and `gu` rather than the default conflicted diffget mappings
let g:diffget_local_map = 'gl'
let g:diffget_upstream_map = 'gu'

" sign-column flags only check for git status by default
let g:signify_vcs_list = ['git']


" SESSION MANAGER

" Set temp file location
let g:pickMeUpSessionDir = s:MakeDir(s:TmpDir . 'sessions')

" ',ss' will prompt to save a named session
exe "map \<leader>ss :\<C-u>SaveSession " . g:pickMeUpSessionDir

" ',sr' will prompt to restore a named session
exe "map \<leader>sr :\<C-u>RestoreSession " . g:pickMeUpSessionDir

" ',sd' will prompt to delete a named session
exe "map \<leader>sd :\<C-u>DeleteSession " . g:pickMeUpSessionDir


" UNDO

" ',uh' will Toggle interactive undo-history
map <leader>uh :GundoToggle<CR>

" Temporarily toggle conceal to fix undo behavior
map u :call ToggleConceal(0) \| undo \| :call ToggleConceal(1)<CR>

" Prevent <Esc>u from accidentally inserting special character 'õ' in insert-mode
" (Use 'Ctrl-v,245' to insert 'õ' intentionally)
inoremap õ <C-\><C-n>u


" VISUALS

" Customize the start screen
let g:Startscreen_function = function('<SID>StartScreen')

" Customize how folded lines are displayed
set foldtext=MyFoldText()

" Always show the sign column
set signcolumn=yes

" ',c' will toggle concealed text
map <leader>c :call ToggleConceal()<CR>

" Set visual wrap indicator
set showbreak=⋯ " ↪

" ',-' will toggle cursor line
map <leader>- :set cursorline!<CR>

" ',|' will toggle cursor column
map <leader><bar> :set cursorcolumn!<CR>:call ToggleConceal(!&cursorcolumn)<CR>

" ',+' will toggle both
map <leader>+ :set cursorline! cursorcolumn!<CR>:call ToggleConceal(!&cursorcolumn)<CR>

" Do not show mode below the statusline
set noshowmode


" STATUSLINE

" Use custom expression to build statusline
set statusline=%!MyStatus()

" ',vs' will toggle verbose statusline
map <silent> <leader>vs :call <SID>ToggleVerboseStatus()<CR>


" FOCUS-MODE

" Increase width from default 80 characters
let g:goyo_width = 100

" Trigger custom-handlers when enabling/disabling focus-mode
autocmd! User GoyoEnter nested call <SID>Focus()
autocmd! User GoyoLeave nested call <SID>Blur()

" Toggle focus-mode
map <silent> <leader><leader> :Goyo<CR>


" VIM SCRIPTING

" Display syntax information
map gs :call <SID>SynGroup()<CR>


" *** Delayed Configuration **************************************************

" PLUGINS

" Load plugins listed in /.vim/plugs
let s:plugins = readfile($HOME . '/.vim/plugs')
call plug#begin('~/.vim/bundle')
call map(s:plugins, {_, p -> s:Plugin(p)})
call plug#end()

" POST-PLUGIN CONFIGURATION

" Set colorscheme
" dark: alduin antares apprentice hybrid_material iceberg PaperColor
" light: disciple earendel lightning
" base16: noctu
colorscheme apprentice " loading this first can improve other colorschemes
colorscheme alduin
call SetDefaultStatusModeHLGroups()

