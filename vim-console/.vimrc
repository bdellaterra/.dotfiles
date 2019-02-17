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
function s:ToggleConceal(...)
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
endfunction

" Get full file path for current buffer or # buffer if command-count provided
function s:BufferFile(...)
  let fnameMods = get(a:000, 0, '')
  return expand((v:count ? '#'.v:count : '%') . ':p' . fnameMods)
endfunction

" Share yanked text with system clipboard when Vim lacks 'clipboard' support
" Note: Paste should work via Shift-Insert or similar terminal keymap
if executable('xclip') | let s:clip = 'xclip' | endif
if executable('pbcopy') | let s:clip = 'pbcopy' | endif
function s:CopyToClipboard(text, ...)
  let register = get(a:000, 0, '')
  if exists('s:clip') && register == ''
    call system(s:clip, a:text)
  endif
endfunction

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
    autocmd VerticallyCenterCursor CursorMoved * normal zz
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
endfunction

" Set statusline highlight based on current mode
function! s:StatusModeHL()
  let mode = mode()
  if mode =~ '\vi|R' " '=~#' to match case
    return &readonly ? '%2*' : '%1*'
  elseif mode =~ '\vv|s|'
    return '%3*'
  endif
  return !&modifiable ? '%4*' : '%*'
endfunction

" Set statusline to deemphasized highlighting
function! s:StatusNoHL()
  return '%#SignColumn#'
endfunction

" Generate unicode bar to represent progress through file
function s:StatusPercentBar()
  let g:pb = ['█', '▇', '▆', '▅', '▄', '▃', '▂', '▁']
  let percent = (1.0 * line('.')) / line('$')
  let index = float2nr(round((len(g:pb) - 1) * percent))
  return g:pb[index]
endfunction

" Toggle between more and less verbose variations of statusline
function s:ToggleVerboseStatus()
  if !exists('s:verboseStatus') || !s:verboseStatus
    let s:verboseStatus = 1
  else
    let s:verboseStatus = 0
  endif
endfunction

" Generate custom statusline
function MyStatus()
  let corner = s:StatusModeHL() . '▒▒' . s:StatusNoHL()
  let line = &number ? '' : printf('%5d', line('.'))
  let col = printf('%3d', col('.'))
  let pos = line != '' ? line . ' ' . col : col
  let mod = &modified ? '…' : ''
  let ro = &modifiable && &readonly ? '' : ''
  let ft = &filetype != '' ? &filetype : 'unknown'
  let ff = &fileformat != '' ? '/' . &fileformat : ''
  let fe = &fileencoding != '' ? '/' . &fileencoding : ''
  let bomb = &bomb ? '※' : ''
  let file = '%f' . (mod != '' ? mod : ' ') . (ro != '' ? ' ' . ro : '')
  let fileInfo = exists('s:verboseStatus') && s:verboseStatus
    \ ? '⟦' . ft . ff . fe . bomb . '⟧' : ''
  let pb = s:StatusPercentBar()
  return corner . ' ' . file . ' ' . fileInfo . '%=' . ' ' . pos . '  ' . pb
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

" Have all folds open when a new file is loaded
set foldlevelstart=999

" Prevent "Hit enter to continue" message
set shortmess+=T
" Further reduce prompts by increasing the height of the command line
set cmdheight=1

" Set default tabbing behavior
set shiftwidth=4
set tabstop=4
set expandtab

" Always show status line
set laststatus=2

" Use modern encoding
set encoding=utf8

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

" enable mouse if supported
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

" Share system clipboard with unnamed register for copy/paste
if has('clipboard')
  set clipboard=unnamed,unnamedplus
else
  autocmd TextYankPost * :call <SID>CopyToClipboard(v:event.regcontents, v:event.regname)
endif


" FILE MANAGER

" Replace default file manager when viewing directories
let g:ranger_replace_netrw = 1

" Set temp file location
let g:ranger_choice_file = s:TmpDir . '/RangerChosenFile'

" Don't use plugin mappings
let g:ranger_map_keys = 0

" ',.' will browse files at current buffer's directory
map <leader>. :Ranger<CR>

" ',f' will browse files at working-directory (usually project root)
map <leader>f :RangerWorkingDirectory<CR>


" MOVEMENT

" '}' will jump down to start of next paragraph, not blank line before
noremap } }}{<Enter>

" '{' will jump up to start of paragraph, not blank line before
noremap { {{<Enter>


" WINDOWS

" Save current buffer when leaving Vim for another Tmux pane
let g:tmux_navigator_save_on_switch = 1

" Don't leave Vim while it's in a zoomed Tmux pane
let g:tmux_navigator_disable_when_zoomed = 1

" Ctrl + movement keys to switch windows w/ Tmux awareness
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-Left>  :TmuxNavigateLeft<CR>
nnoremap <silent> <C-h>       :TmuxNavigateLeft<CR>
nnoremap <silent> <C-Down>  :TmuxNavigateDown<CR>
nnoremap <silent> <C-j>       :TmuxNavigateDown<CR>
nnoremap <silent> <C-Up>    :TmuxNavigateUp<CR>
nnoremap <silent> <C-k>       :TmuxNavigateUp<CR>
nnoremap <silent> <C-Right> :TmuxNavigateRight<CR>
nnoremap <silent> <C-l>       :TmuxNavigateRight<CR>

" Ctrl-w + window-movement to open window in that direction
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

" Show buffers if two or more are open
let g:buftabline_show = 2

" Show buffer numbers
let g:buftabline_numbers = 1

" Show separators between buffer names
let g:buftabline_separators = 0

" If used after a numeric count the equals key switches to that number buffer.
" Number zero signifies the althernate buffer. (See :help alternate-file)
" Otherwise the default re-indent behavior is used.
noremap <expr>= <SID>EditBufferOrReindent(v:count)
noremap 0= :<C-u>confirm buffer #<CR>  " Vim won't pass zero-counts to mappings

" '-=' will delete current buffer or # buffer number via command-count
nnoremap -= :<C-u>exe (v:count ? v:count : '') . 'bdelete'<CR>
nnoremap 0-= :<C-u>confirm bdelete #<CR>
" Alias 'Ctrl-w,Ctrl-w'
nmap <C-w><C-w> -=
nmap 0<C-w><C-w> 0-=

" '+=' will prompt for editing a file with filename needing to be specified.
" Path will be same as the current buffer or # buffer via command-count
nnoremap += :<C-u>edit <C-r>=<SID>BufferFile(':h') . '/'<CR>

" '=]' will switch to previous buffer, or command-count buffers back
nnoremap =] :<C-u>exe (v:count ? v:count : '') . 'bnext'<CR>
" Alias 'Tab'
nmap <Tab> =]

" '=[' will switch to previous buffer, or command-count buffers back
nnoremap =[ :<C-u>exe (v:count ? v:count : '') . 'bprev'<CR>
" Alias 'Shift-Tab'
nmap <S-Tab> =[


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

" Auto-complete without hitting <Tab>
let g:mucomplete#enable_auto_at_startup = 1


" FUZZY-FIND
" (All commands are prefized with <leader>/)

map <leader>/p   :Files 
map <leader>/~   :Files ~<CR>
map <leader>/.   :<C-u>Files <C-r>=<SID>BufferFile(':h') . '/'<CR><CR>
map <leader>/f   :exe 'Files ' . ProjectRootGuess()<CR> " requires ProjectRoot plugin
map <leader>/gf  :GFiles<CR>
map <leader>/gs  :GFiles?<CR>
map <leader>/b   :Buffers<CR>
map <leader>/cs  :Colors<CR>
map <leader>/l   :Lines<CR>
map <leader>/bl  :BLines<CR>
map <leader>/tg  :Tags<CR>
map <leader>/tb  :BTags<CR>
map <leader>/'   :Marks<CR>
map <leader>/`   :Marks<CR>
map <leader>/w   :Windows<CR>
map <leader>/ml  :Locate<CR>
map <leader>/h   :History<CR>
map <leader>/:   :History:<CR>
map <leader>//   :History/<CR>
map <leader>/s   :Snippets<CR>
map <leader>/cm  :Commands<CR>
map <leader>/mp  :Maps<CR>
map <leader>/?   :Helptags<CR>
map <leader>/gg  :Commits<CR> " Requires Fugitive plugin
map <leader>/gbg :BCommits<CR>
if executable('ag') " https://github.com/ggreer/the_silver_searcher
  map <leader>/r   :Ag<CR>
endif
if executable('rg') " https://github.com/BurntSushi/ripgrep
  map <leader>/r   :Rg<CR>
endif


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

" ',l' will auto-fix linter errors (without saving)
map <leader><Enter> :ALEFix && %foldopen!<CR> " unclear why ALEFix closes folds


" FOLD

" Initial fold regions based on syntax-rules
set foldmethod=syntax

" Open all folds by default
set foldlevelstart=99

" Automatically open folds in insert-mode
set foldopen=all

" Customize how folded lines are displayed
set foldtext=MyFoldText()


" SESSION MANAGER

" Set temp file location
let g:pickMeUpSessionDir = s:TmpDir


" UNDO

" ',uh' will Toggle interactive undo-history
map <leader>uh :GundoToggle<CR>

" Temporarily toggle conceal to fix undo behavior
map u :call <SID>ToggleConceal(0) \| undo \| :call <SID>ToggleConceal(1)<CR>

" Prevent <Esc>u from accidentally inserting special character 'õ' in insert-mode
" (Use 'Ctrl-[,u' if you need to achieve the same thing)
inoremap <Esc>u <C-\><C-n>u


" VISUALS

" Always show the sign column
set signcolumn=yes

" ',c' will toggle concealed text
map <leader>c :call <SID>ToggleConceal()<CR>

" Set visual wrap indicator
set showbreak=⋯ " ↪

" ',-' will toggle cursor line
map <leader>- :set cursorline!<CR>

" ',|' will toggle cursor column
map <leader><bar> :set cursorcolumn!<CR>:call <SID>ToggleConceal(!&cursorcolumn)<CR>

" ',+' will toggle both
map <leader>+ :set cursorline! cursorcolumn!<CR>:call <SID>ToggleConceal(!&cursorcolumn)<CR>

" Do not show mode below the statusline
set noshowmode


" STATUSLINE

" Set highlight groups used in statusline
highlight link User1 ModeMsg
highlight link User2 ErrorMsg
highlight link User3 DiffChange
highlight link User4 BufTabLineActive

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
map <leader><leader> :Goyo<CR>


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
colorscheme apprentice

