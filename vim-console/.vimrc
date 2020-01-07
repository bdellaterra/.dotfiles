" *** Inital Configuration ****************************************************

" PLUGIN MANAGER

" Auto-install plug.vim
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" SHARED FUNCTIONS

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

" Create file if necessary and normalize slashes
function MakeFile(path, ...)
  try
    let file = fnamemodify(a:path, ':t')
    let dir = s:DirSlashes(fnamemodify(a:path, ':h'))
    let bufferDir = s:DirSlashes(fnamemodify(expand('%'), ':p:h'))
    let projectDir = s:DirSlashes(fnamemodify(get(a:000, 0, $PWD), ':p'))
    " full path
    if dir =~ bufferDir
      let targetDir = dir
    " relative path
    elseif dir =~ '^\V..\?/'
      let targetDir = s:DirSlashes(fnamemodify(bufferDir . dir, ':.'))
    " existing project path
    elseif isdirectory(projectDir . dir)
      let targetDir = projectDir . dir
    " just filename
    elseif dir == '' && isdirectory(bufferDir)
      let targetDir = bufferDir
    endif
    if exists('targetDir')
      call s:MakeDir(targetDir)
      let file = targetDir . file
      if filewritable(file)
        call writefile([], file, 'a')
      endif
    endif
  endtry
  return file
endfunction

" Get full file path for current buffer or # buffer if command-count provided
function s:BufferFile(...)
  let fnameMods = get(a:000, 0, '')
  return expand((v:count ? '#'.v:count : '%') . ':p' . fnameMods)
endfunction

" Calculate ideal position for cursor to settle during scrolling
function! s:CursorRatio()
  return float2nr(round(winheight(0) * 0.381966))
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

" Returns boolean indicating if cursor is currently over a concealed syntax region
function s:IsCursorOverConcealed()
  return synconcealed(line('.'), col('.'))[0]
endfunction

" Toggle between conceallevel 0 and 2. Pass optional boolean
" to disable temporarily (false) or restore last on/off setting (true)
augroup ToggleConceal
  autocmd!
  autocmd FileType * call <SID>ReinforceConcealSyntax()
  autocmd CursorHold * call <SID>UpdateTime()
  autocmd TextChanged * call <SID>RevealLine(1)
  autocmd InsertLeave * call <SID>RevealLine(0)
augroup END
function s:ReinforceConcealSyntax()
  if !exists('g:disableConcealSyntax') || !g:disableConcealSyntax
    if &conceallevel
      silent! exe 'source ~/.dotfiles/vim-console/.vim/after/syntax/' . &filetype . '.vim'
    endif
  endif
endfunction
function s:UpdateTime(...)
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
function s:RevealLine(...)
  if !exists('g:disableConcealSyntax') || !g:disableConcealSyntax
    let unconcealLine = get(a:000, 0, 0)
    if unconcealLine
      set concealcursor=
    else
      set concealcursor=n
    endif
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
    " Make cursor position more accurate with faster updates
    noremap <expr> <Up> <SID>RevealLine(0) && UpdateTime(10)
      \ ? "\<Up>" : "\<Up>"
    noremap <expr> <Down> <SID>RevealLine(0) && UpdateTime(10)
      \ ? "\<Down>" : "\<Down>"
    noremap <expr> <Left> <SID>UpdateTime(10)
      \ ? "\<Left>" : "\<Left>"
    noremap <expr> <Right> <SID>UpdateTime(10)
      \ ? "\<Right>" : "\<Right>"
  endif
endfunction

" Overload behavior of the enter key
function s:EnterHelper(...)
  try
    normal gf
  catch
    LspDefinition
  catch
    LspDeclaration
  catch
    exe "normal \<C-]>"
  catch
    LspImplementation
  endtry
endfunction

" Show syntax group and translated syntax group of character under cursor
" Will look at syntax v:count lines below cursor if a count is specified
" If optional boolean true is passed, will look v:count lines above cursor
" (Modified) From Laurence Gonsalves, 2016, https://stackoverflow.com/questions/9464844/how-to-get-group-name-of-highlighting-under-cursor-in-vim
function! s:SynGroup(...)
  let reverse = get(a:000, 0, 0)
  let l:s = synID(line('.') + v:count * (reverse ? -1 : 1), col('.'), 1)
  return synIDattr(l:s, 'name') . ' ->  ' . synIDattr(synIDtrans(l:s), 'name')
endfunction

" Move cursor through next whitespace in current column. Lands on non-whitespace
" character after the gap. Optional boolean triggers backwards search if true
function s:GoToNextVerticalNonBlank(...)
  let reverse = get(a:000, 0, 0)
  let col = virtcol('.') 
  let lastsearch=@/
  let blank = 1
  while blank
    call search('\(^\s*$\)\|\%' . col . 'v\s', reverse ? 'b' : '')
    call search('\%' . col . 'v\S', reverse ? 'b' : '')
    let blank = s:SynGroup() =~ '\<Ignore$'
  endwhile
  let @/=lastsearch
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


" CLIPBOARD

" Detect system clipboard utilities:

" nix
if executable('xclip')
  let s:clipCopy = 'xclip'
  let s:clipPaste = 'xclip -o'
endif

" mac
if executable('pbcopy')
  let s:clipCopy = 'pbcopy'
  let s:clipPaste = 'pbpaste' " mac
endif

" win
" (Symlink executables to ~/bin path under Windows Subsystem for Linux)

" Default (with no paste support) at /mnt/c/Windows/System32/clip.exe
if executable('clip')
  let s:clipCopy = 'clip'
endif

" Install from https://github.com/equalsraf/win32yank/releases
if executable('win32yank') && executable('unix2dos')
  let s:clipCopy = 'unix2dos | win32yank -i'
  let s:clipPaste = 'win32yank -o | dos2unix'
endif

" Share yanked text with system clipboard, even when Vim lacks 'clipboard' support
function s:CopyToClipboard(text, ...)
  let register = get(a:000, 0, '')
  if !has('clipboard')
    if exists('s:clipCopy') && register == ''
      call system(s:clipCopy, a:text)
    endif
  else
    call setreg('+', a:text)
  endif
  if register != ''
    call setreg(register, a:text)
  endif
endfunction

" Sync system clipboard with Vim for paste-support
function s:PasteFromClipboard()
  if exists('s:clipPaste')
    let @" = system(s:clipPaste)
  endif
endfunction

" Share system clipboard for copy/paste events
if has('clipboard')
  set clipboard=unnamed,unnamedplus
else
  autocmd TextYankPost * :call <SID>CopyToClipboard(v:event.regcontents, v:event.regname)
  autocmd FocusGained * :call <SID>PasteFromClipboard()
endif

" 'F12' will toggle paste mode, which disables auto-formatting of copy/pasted text
noremap <F12> :set paste! paste?<CR>
imap <expr> <F12> set paste! paste? ? '' : ''


" FILES

" Replace default file manager when viewing directories
let g:ranger_replace_netrw = 1

" Set temp file location
let g:ranger_choice_file = s:TmpDir . 'RangerChosenFile'

" Don't use plugin mappings
let g:ranger_map_keys = 0

" ',.' will browse files at current buffer's directory
map <leader>. :Ranger<CR>

" ',p' will browse files at working-directory (usually project root)
map <leader>p :RangerWorkingDirectory<CR>

" ',wd' will copy working directory to the clipboard
map <silent> <leader>wd :call <SID>CopyToClipboard(fnamemodify(bufname(''),':p:h'), '"')<CR>

" ',wf' will copy working file (full-path) to the clipboard
map <silent> <leader>wf :call <SID>CopyToClipboard(fnamemodify(bufname(''),':p', '"'))<CR>

" ',wt' will copy "tail" of working path to the clipboard (just the filename)
map <silent> <leader>wt :call <SID>CopyToClipboard(fnamemodify(bufname(''),':p:t', '"'))<CR>

" Automatically create missing parent directories when editing a new file
autocmd BufWritePre * :call s:MakeDir(fnamemodify(expand('<afile>'), ':p:h'))

" 'Enter' will go to file under cursor
map <Enter> :call <SID>EnterHelper()<CR>

" ',Enter' will go to file under cursor, creating it if necessary
map <leader><Enter> :exe 'edit ' . MakeFile(expand('<cfile>'))<CR>

" 'Backspace' will go back
map <Backspace> <C-o>


" SELECTION

" In input mode, Ctrl + movement keys initiate visual selection
inoremap <C-Left>  <C-\><C-n>v
" inoremap <C-h>     <C-\><C-n>v
inoremap <expr> <C-Down>  "\<C-o>v\<Down>\<Left>"
" inoremap <expr> <C-j>     "\<C-o>v\<Down>\<Left>"
inoremap <expr> <C-Up>    "\<C-\>\<C-n>v\<Up>" . (col('.')>1?"\<Right>":"")
inoremap <expr> <C-k>     "\<C-\>\<C-n>v\<Up>" . (col('.')>1?"\<Right>":"")
inoremap <C-Right> <C-o>v
inoremap <C-l>     <C-o>v


" MOVEMENT

" '}' will jump down to start of next paragraph, not blank line before
noremap } }}{<Enter>

" '{' will jump up to start of paragraph, not blank line before
noremap { {{<Enter>

" '\' will jump down to next non-blank character in current column
nnoremap \ :silent! call <SID>GoToNextVerticalNonBlank()<CR>

" '|' will jump up to previous non-blank character in current column
nnoremap \| :silent! call <SID>GoToNextVerticalNonBlank(1)<CR>

" ',m' will mark current location (VimPager plugin)
map <Leader>m <Plug>SaveWinPosn

" ',j' will jump to last marked location
map <Leader>j <Plug>RestoreWinPosn


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

" When switching buffers, preserve window view.
" From Ipkiss, 2007, https://vim.fandom.com/wiki/Avoid_scrolling_when_switch_buffers
if v:version >= 700
  au BufLeave * if !&diff | let b:winview = winsaveview() | endif
  au BufEnter * if exists('b:winview') && !&diff | call winrestview(b:winview) | unlet! b:winview | endif
endif


" INDENTATION

" for efficiency, don't auto-detect indentation settings
let g:sleuth_automatic = 0


" ALIGNMENT

" 'ga' wil start interactive EasyAlign in visual mode (e.g. vip,a)
xmap ga <Plug>(EasyAlign)

" 'ga' will start interactive EasyAlign for a motion/text object (e.g. ,aip)
nmap ga <Plug>(EasyAlign)


" LANGUAGE SUPPORT

let g:lsp_diagnostics_enabled = 1
let g:lsp_signs_enabled = 0
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_signs_error = {'text': '•'}
let g:lsp_signs_warning = {'text': '▶'}
let g:lsp_textprop_enabled = 1

let g:lsp_highlights_enabled = 0

function! s:on_lsp_buffer_enabled() abort
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
	nmap <buffer> GV <plug>(lsp-hover)
	nmap <buffer> GA <plug>(lsp-code-action)
	nmap <buffer> GS <plug>(lsp-status)
    nmap <buffer> GC :let g:lsp_highlight_references_enabled = !g:lsp_highlight_references_enabled<CR>
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]
let g:vista_default_executive = 'vim_lsp'
let g:vista_fzf_preview = ['right:50%']
let g:vista_disable_statusline = 1
let g:vista#renderer#enable_icon = 1
let g:vista#renderer#icons = {
      \   "function": "\uf794",
      \   "variable": "\uf71b",
      \  }


" COMPLETION

" Show completion menu even with one item. Do not auto-select option
set completeopt=menu,menuone,noinsert,noselect

" Shut off completion messages and beeps
set shortmess+=c
set belloff+=ctrlg

" <C-Up> amd <C-Down> will peform command line completion using buffer info
" (Works with ':', '/' and '?' commands)
cmap <c-Up> <Plug>CmdlineCompleteBackward
cmap <c-Down> <Plug>CmdlineCompleteForward


" LINTING

" ',k' will toggle spell-check highlighting
map <leader>k :set spell! spell?<CR>


" DELIMITERS

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
map <leader>gl  :Commits<CR>
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

" Enable conceal syntax that would be redundant with font ligatures
" Set to true if using a font that supports programming ligatures
let g:font_ligatures_enabled = 0

" Set visual wrap indicator
set showbreak=⋯ " ↪

" Always show the sign column
set signcolumn=yes

" Do not show mode below the statusline
set noshowmode

" '/<Backspace>' will toggle search highlighting
map /<Backspace> :set hls!<CR>

" ',c' will toggle concealed text
map <leader>c :call ToggleConceal()<CR>

" ',-' will toggle cursor line
map <leader>- :set cursorline!<CR>

" ',|' will toggle cursor column
map <leader><bar> :set cursorcolumn!<CR>:call ToggleConceal(!&cursorcolumn)<CR>

" ',+' will toggle both
map <leader>+ :set cursorline! cursorcolumn!<CR>:call ToggleConceal(!&cursorcolumn)<CR>


" FOLDING

" Initial fold regions based on syntax-rules
set foldmethod=syntax

" Have all folds open when a new file is loaded
set foldlevelstart=999

" Automatically open/close folds in insert-mode
set foldopen=all
set foldclose=all

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

" Customize how folded lines are displayed
set foldtext=MyFoldText()


" STATUSLINE

" Set highlight groups used in statusline
function SetDefaultStatusModeHLGroups()
  highlight User1 ctermfg=233 ctermbg=145
  highlight User2 ctermfg=233 ctermbg=11
  highlight User3 ctermfg=233 ctermbg=231
  highlight User4 ctermfg=233 ctermbg=88
  highlight User5 ctermfg=233 ctermbg=123
  highlight User6 ctermfg=233 ctermbg=240
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
  " User6 if over concealed syntax
  if s:IsCursorOverConcealed()
    return '%6*'
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
  \ 'n':'ƞ', 'v':'ⱱ', 'V':'Ⅴ', '':'⋎', 's':'ș', 'S':'Ṣ',
  \ 'i':'∣', 'R':'Ɍ', 'c':'ċ', 'r':'ṙ', '!':'⟳', 't':'ẗ'
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
    let file = (verbose ? '%f' : '%t')
      \ . (mod != '' ? mod : ' ')
      \ . (ro != '' ? ' ' . ro : '')
    let branch = verbose ? ' ｢' . FugitiveHead() . '｣ ' : ''
    let mode = verbose ? get(s:statusModeSymbols, mode(), '') : ''
    let conceal = verbose && &conceallevel ? '␦' : ''
    let paste = &paste ? '⎘' : '' " ⎀ϊǐ
    let modeInfo = mode . conceal . paste
    let fileInfo = verbose ? ff . fe . ft . bomb . '  ⋰⋰' : ''
    let pb = s:StatusPercentBar()
    let datetime = verbose ? ' ' . strftime('%d/%b %H:%M') . ' ' : ''
    let leftSide = ' %<' . ' ' . file . branch 
    let rightMinWidth = string(s:MaxLineWidth() - s:statusWidth)
    let rightSide = modeInfo . '  ' . fileInfo . pos . '  ' . pb
    return corner . leftSide . ' %= '
      \ . '%#TabLine# ' . datetime . ' ' . rightSide
  catch
    return v:exception
  endtry
endfunction

" Use custom expression to build statusline
set statusline=%!MyStatus()

" ',vs' will toggle verbose statusline
map <silent> <leader>vs :call <SID>ToggleVerboseStatus()<CR>


" FOCUS-MODE

" Apply focus-mode customizations
function! s:Focus()
  if !exists('g:limelight_conceal_ctermfg')
   let g:limelight_conceal_ctermfg = 239
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
  silent! unlet s:save_showtabline
  set showmode
  set showcmd
  Limelight!
  " Restore User Highlight groups that are being cleared for some reason
  call SetDefaultStatusModeHLGroups()
  " Reset filetype to fix concealed syntax highlighting
  exe 'set filetype=' . &filetype
endfunction

" Increase width from default 80 characters
let g:goyo_width = 100

" Trigger custom-handlers when enabling/disabling focus-mode
autocmd! User GoyoEnter nested call <SID>Focus()
autocmd! User GoyoLeave nested call <SID>Blur()

" Toggle focus-mode
map <silent> <leader><leader> :Goyo<CR>


" STARTSCREEN

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

" Customize the start screen
let g:Startscreen_function = function('<SID>StartScreen')


" INFO

" 'gs' will display syntax information for highlighting at cursor position.
" Specify count to look at syntax that number of lines below cursor
map gs :<C-u>echo <SID>SynGroup()<CR>

" 'gs' will display syntax information for highlighting at cursor position.
" Specify count to look at syntax that number of lines above cursor
map gS :<C-u>echo <SID>SynGroup(1)<CR>

" 'gu' will display unicode metadata for character under cursor
nmap gu <Plug>(characterize)


" *** Delayed Configuration **************************************************

" PLUGINS

" Support loading plugin/options from file w/ empty lines and comments removed
function s:Plugin(plug)
  let [locator, options] = matchlist(a:plug, '\v^([^# ]*)\s*(\{[^}#]*\})?')[1:2]
  if len(locator)
    call call('plug#', len(options) ? [locator, eval(options)] : [locator])
  end
endfunction

" Load plugins listed in /.vim/plugs
let s:plugins = readfile($HOME . '/.vim/plugs')
call plug#begin('~/.vim/bundle')
call map(s:plugins, {_, p -> s:Plugin(p)})
call plug#end()

" POST-PLUGIN CONFIGURATION

" Set colorscheme
" dark: alduin antares apprentice hybrid_material iceberg OceanicNext PaperColor
" light: disciple earendel lightning
" base16: noctu
colorscheme apprentice " loading this first can improve other colorschemes
call SetDefaultStatusModeHLGroups()

" Source personal configurations, if present
if filereadable($HOME . '/.vim/personal.vim')
  exe 'source ' . $HOME . '/.vim/personal.vim'
endif

" Source work configurations, if present
if filereadable($HOME . '/.vim/business.vim')
  exe 'source ' . $HOME . '/.vim/business.vim'
endif

