" *** Inital Configuration ****************************************************

" PLUGIN MANAGER

" Auto-install plug.vim
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" CONSTANTS

if has("win64") || has("win32")
  let g:os = matchstr(rc#trim(system('systeminfo | findstr /B /C:"OS Name"')), '\(OS Name:\s*\)\?\zs.*')
elseif executable('uname')
  let g:os = rc#trim(system('uname -s'))
endif


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

" Display most of a last line that doesn't fit in the window
set display=lastline

" Auto-save when opening/changing buffers
set autowriteall

" Set directory where temporary files can be stored
let s:TmpDir = rc#MakeDir($HOME . '/tmp/vim')

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
autocmd InsertEnter,CursorMoved,CursorMovedI,CursorHold,CursorHoldI *
  \ if getcmdwintype() == '' | checktime | endif

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

" *nix
if executable('xclip')
  let g:clipCopy = 'xclip'
  let g:clipPaste = 'xclip -o'
endif

" mac
if executable('pbcopy')
  let g:clipCopy = 'pbcopy'
  let g:clipPaste = 'pbpaste'
endif

" win
" (Symlink executables to ~/bin path under Windows Subsystem for Linux)

" Default (with no paste support) at /mnt/c/Windows/System32/clip.exe
if has('windows') || has("win64") || has("win32")
  if executable('clip')
    let g:clipCopy = 'clip'
  endif

  " Install from https://github.com/equalsraf/win32yank/releases
  if executable('win32yank') && executable('unix2dos')
    let g:clipCopy = 'unix2dos | win32yank -i'
    let g:clipPaste = 'win32yank -o | dos2unix'
  endif
endif

" Share system clipboard for copy/paste events
if has('clipboard')
  set clipboard=unnamed,unnamedplus
else
  autocmd TextYankPost * :call rc#CopyToClipboard(v:event.regcontents, v:event.regname)
  autocmd FocusGained * :call rc#PasteFromClipboard()
endif

" Prevent paste from overwriting registers with replaced text
" From rox, 2017, https://stackoverflow.com/questions/290465/how-to-paste-over-without-overwriting-register 
xnoremap <expr> p 'pgv"'.v:register.'y`>'

" 'F12' will toggle paste mode, which disables auto-formatting of copy/pasted text
noremap <F12> :set paste! paste?<CR>
imap <expr> <F12> set paste! paste? ? '' : ''


" FILES

command! -nargs=* BZB
  \ silent! call bzb#BZB(<q-args>)

" Replace default file manager when viewing directories
" let g:ranger_replace_netrw = 1
augroup ReplaceNetrwWithBzb
  autocmd!
  autocmd VimEnter * silent! autocmd! FileExplorer
  autocmd BufEnter * if isdirectory(expand("%")) | set nobuflisted | exe 'BZB ' . expand('%')
augroup END

" Set temp file location
let g:ranger_choice_file = s:TmpDir . 'RangerChosenFile'

" Don't use plugin mappings
let g:ranger_map_keys = 0

" ',.' will browse files at current buffer's directory (BZB)
map <silent> <leader>. :silent! call bzb#BZB()<CR>

" ',;' will browse files at current buffer's directory (Ranger)
map <leader>; :Ranger<CR>

" ',p' will browse files at working-directory (usually project root)
" map <leader>p :RangerWorkingDirectory<CR>
map <leader>p :silent! call bzb#BZB(ProjectRootGuess())<CR>

" ',wd' will copy working directory to the clipboard
map <silent> <leader>wd :call rc#CopyToClipboard(fnamemodify(bufname(''),':p:h'), '"')<CR>

" ',wf' will copy working file (full-path) to the clipboard
map <silent> <leader>wf :call rc#CopyToClipboard(fnamemodify(bufname(''),':p'), '"')<CR>

" ',wr' will copy working file (relative-path) to the clipboard
map <silent> <leader>wr :echo '.' . rc#CopyToClipboard(substitute(
  \ fnamemodify(bufname(''), ':p'), fnamemodify(ProjectRootGuess(), ':p:h'), '', ''), '"')<CR>

" ',ws' will copy working file (short-path) to the clipboard
map <silent> <leader>ws :echo rc#CopyToClipboard(
  \ substitute(
  \   substitute(fnamemodify(bufname(''), ':p:r'), fnamemodify(ProjectRootGuess(), ':p:h') . '/', '', ''),
  \ '^\(src/\)\?\(.\{-}\)\(/index\)\?$', '\2', ''),
  \ '"')<CR>

" ',wt' will copy "tail" of working path to the clipboard (just the filename)
map <silent> <leader>wt :call rc#CopyToClipboard(fnamemodify(bufname(''),':p:t'), '"')<CR>

" Automatically create missing parent directories when editing a new file
autocmd BufWritePre * :call rc#MakeDir(fnamemodify(expand('<afile>'), ':p:h'))

" 'Enter' will go to file/url/tag/definition/declaration under cursor
map <silent> <Enter> :call rc_vue#EnterHelper()<CR>

" ',Enter' or Alt-Enter will go to file, creating it if necessary
" or open URL in external web browser
map <silent> <leader><Enter> :call rc_vue#EnterHelper(1)<CR>
map <silent> <M-Enter> :call rc_vue#EnterHelper(1)<CR>

" '\Enter' will read markdown from url and save it to file entered at prompt
map <silent> \<Enter> :call rc_vue#EnterHelper(2)<CR>

" Go count forward/backward in the list of Most Recently Used files
autocmd BufAdd,BufDelete,CursorHold,CursorHoldI * :let g:mruFiles = [] | let g:mruIndex = 0

" '-' will go back in the MRU list
nnoremap <silent> - :call rc#JumpMRU(-1)<CR>

" '+' will go forward in the MRU list
nnoremap <silent> + :call rc#JumpMRU(1)<CR>


" URLS

" Set temp file location
let g:wwwDir = s:TmpDir . 'www/'

" Set appropriate filetype for temporary html files converted to markdown (path matches url)
exe  'autocmd BufRead,BufNewFile ' . g:wwwDir . '*' . ' set filetype=pandoc'

command! -nargs=1 VUE
      \ call rc_vue#ReadUrl(<q-args>)
command! -nargs=1 VUB
      \ call rc_vue#GoToUrl(<q-args>, 1)

" Browse URLs
map <leader>vv :VUE 
map <leader>VV :VUB 

" Dictionary
let g:onlineDictionary = 'https://www.wordnik.com/words/'
map <silent> <leader>vd :exe "call rc_vue#ReadUrl('" . g:onlineDictionary .input('Online Dictionary Search: ') . "')"<CR>
map <silent> <leader>VD :exe "call rc_vue#GoToUrl('" . g:onlineDictionary .input('Online Dictionary Search: ') . "')"<CR>

" Thesaurus
let g:onlineThesaurus = 'https://www.thesaurus.com/browse/'
map <silent> <leader>vt :exe "call rc_vue#ReadUrl('" . g:onlineThesaurus .input('Online Thesaurus Search: ') . "')"<CR>
map <silent> <leader>VT :exe "call rc_vue#GoToUrl('" . g:onlineThesaurus .input('Online Thesaurus Search: ') . "')"<CR>

" Etymology
let g:onlineEtymology = 'https://www.etymonline.com/search?q='
map <silent> <leader>ve :exe "call rc_vue#ReadUrl('" . g:onlineEtymology . input('Online Etymology Search: ') . "')"<CR>
map <silent> <leader>VE :exe "call rc_vue#GoToUrl('" . g:onlineEtymology . input('Online Etymology Search: ') . "')"<CR>

" Web Search
" let g:onlineWebSearch = 'http://localhost/search?q='
let g:onlineWebSearch =  'https://searx.be/search?q='
let g:onlineWebSearch =  'https://anon.sx/search?q='
map <silent> <leader>vs :exe "call rc_vue#ReadUrl('" . g:onlineWebSearch . input('Online Web Search: ') . "!')"<CR>
map <silent> <leader>VS :exe "call rc_vue#GoToUrl('" . g:onlineWebSearch . input('Online Web Search: ') . "!')"<CR>

" Wiki Search
let g:onlineWikiSearch = 'https://en.wikipedia.org/wiki/'
" let g:onlineWikiSearch = 'https://wiki2.org/en/'
map <silent> <leader>vw :exe "call rc_vue#ReadUrl('" . g:onlineWikiSearch . substitute(input('Online Wiki Search: '), ' ', '_', 'g') . "')"<CR>
map <silent> <leader>VW :exe "call rc_vue#GoToUrl('" . g:onlineWikiSearch . substitute(input('Online Wiki Search: '), ' ', '_', 'g') . "')"<CR>

let g:preHtmlToMdCleanup = []
let g:postHtmlToMdCleanup = [
  \ ['www.example.com', rc_vue#MarkdownHeadingJump(1)],
  \ ]

let g:postHtmlToMdCleanup += [
  \ ['dogpile.com', 'silent! %s#^<.*>\n##'],
  \ ]

let g:postHtmlToMdCleanup += [
  \ ['wikipedia.org', 'silent! %s#\[\\\[\(\d\+\)\\\]\]#[^\1]#g'],
  \ ]

let g:postHtmlToMdCleanup += [
  \ ['developer.mozilla.org', 'silent! %s#\[Permalink to \([^]]*\)\].*#\r\1#'],
  \ ['developer.mozilla.org', 'silent! 1s@^\_.*\_^\[# content\]@@'],
  \ ]

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

" '_' will start a visual selection at cursor and expand it with each repeat
 nmap _ <Plug>(expand_region_expand)
 vmap _ <Plug>(expand_region_expand)
 vmap <C-_> <Plug>(expand_region_shrink)
 nmap <C-_> <Plug>(expand_region_shrink)

" MOVEMENT

" '\' will jump down to next non-blank character in current column
nnoremap \ :silent! call rc#GoToNextVerticalNonBlank()<CR>

" '|' will jump up to previous non-blank character in current column
nnoremap \| :silent! call rc#GoToNextVerticalNonBlank(1)<CR>

" ',m' will mark current location (VimPager plugin)
" map <Leader>m <Plug>SaveWinPosn

" ',j' will jump to last marked location
" map <Leader>j <Plug>RestoreWinPosn


" SCROLLING

" lock cursor to optimal location while scrolling
map <expr> <ScrollWheelUp> winline() >= rc#CursorRatio() ? "\<C-e>gj" : 'gj'
map <expr> <ScrollWheelDown> winline() <= rc#CursorRatio() ? "\<C-y>gk" : 'gk'


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
noremap <expr>= rc#EditBufferOrReindent(v:count)
" Vim won't pass zero-counts to mappings
noremap 0= :<C-u>call rc#SwitchToAltBufferOrMruFile()<CR>

" '-=' will delete current buffer or # buffer number from command-count
nnoremap -= :<C-u>exe (v:count ? v:count : '') . 'bdelete!'<CR>
nnoremap 0-= :<C-u>confirm bdelete #<CR>
" Alias 'Ctrl-w,Ctrl-w'
nmap <C-w><C-w> -=
nmap 0<C-w><C-w> 0-=

" '+=' will prompt for editing a file with filename needing to be specified.
" Path will be same as the current buffer or that of # buffer from command-count
nnoremap += :<C-u>edit <C-r>=rc#BufferFile(':h') . '/'<CR>

" '=]' will switch to previous buffer, or command-count buffers back
nnoremap =] :<C-u>exe (v:count ? v:count : '') . 'bnext'<CR>
" Alias 'Tab'
nmap <Tab> =]

" '=[' will switch to previous buffer, or command-count buffers back
nnoremap =[ :<C-u>exe (v:count ? v:count : '') . 'bprev'<CR>
" Alias 'Shift-Tab'
nmap <S-Tab> =[

" '=/' will display active buffers for selection/search
nnoremap =/ :Buffers<CR>
" '=\' will list buffers with fullscreen display
nnoremap =\ :Buffers!<CR>
" Alias 'Backspace'
nmap <Backspace> =\

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
" (Use ':Sleuth' command to do so manually)
let g:sleuth_automatic = 0


" ALIGNMENT

" 'ga' wil start interactive EasyAlign in visual mode (e.g. vip,a)
xmap ga <Plug>(EasyAlign)

" 'ga' will start interactive EasyAlign for a motion/text object (e.g. ,aip)
nmap ga <Plug>(EasyAlign)


" LANGUAGE SUPPORT

function! OnLspBufferEnabled() abort
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

let g:lsp_diagnostics_enabled = 1
let g:lsp_signs_enabled = 0
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_signs_error = {'text': '•'}
let g:lsp_signs_warning = {'text': '▶'}
let g:lsp_textprop_enabled = 1

let g:lsp_highlights_enabled = 0

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call OnLspBufferEnabled()
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


" MARKDOWN
" See .vim/after/ftplugin/pandoc.vim for key mappings

let g:pandoc#filetypes#handled = ["pandoc", "markdown"]
let g:pandoc#folding#fastfolds = 1
let g:pandoc#spell#enabled = 0
let g:pandoc#hypertext#autosave_on_edit_open_link = 1
let g:pandoc#hypertext#create_if_no_alternates_exists = 1
let g:pandoc#syntax#conceal#use = 1
let g:pandoc#syntax#conceal#cchar_overrides = {
  \ 'atx': '░',
  \ 'codelang': '‴',
  \ 'codeend':  '‷'
  \ }
let g:pandoc#syntax#conceal#urls = 1
let g:pandoc#syntax#codeblocks#embeds#use = 1
let g:pandoc#syntax#codeblocks#embeds#langs = [
  \ 'javascript=typescriptreact',
  \ 'typescript=typescriptreact'
  \ ]
let g:pandoc#keyboard#sections#header_style = 's'

augroup VimCompletesMePandoc
  autocmd!
  autocmd FileType pandoc
    \ let b:vcm_omni_pattern = '@'
augroup END

function! AddMarkdownTitle(...)
  let title = get(a:000, 0, fnamemodify(expand('%'), ':t:r'))
  let file = expand('%')
  let g:fmod = getftime(file)
  if !len(readfile(file)) && ( g:fmod < 0 || ((localtime() - g:fmod) <= 1) )
	exe 'normal ggo' . title
	exe 'normal o' . substitute(title, '.', '=', 'g')
	normal o
    write
  endif
endfunction

augroup Skeletons
  autocmd BufNewFile,FileType *.md :call AddMarkdownTitle()
augroup END

" NOTES

let g:nv_search_paths = ['~/notes', '~/wiki']

" ',n' will open bzb in notes directory
noremap <silent> <leader>n :exe '!' . bzb#BZB() . ' -E -bd="' . fnamemodify(g:nv_search_paths[0], ':p')  . '"'<CR>


" TABLES

" ',tm' will toggle vim-table-mode plugin

inoreabbrev <expr> <bar><bar>
          \ rc#IsAtStartOfLine('\|\|') ?
          \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
inoreabbrev <expr> __
          \ rc#IsAtStartOfLine('__') ?
          \ '<c-o>:silent! TableModeDisable<cr>' : '__'

" ',tr' will join selected lines as table row
vnoremap <leader>tr :<C-u>call rc_vue#JoinLinesAsTableRow()<CR>


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

let g:surround_close_subs = [
  \ [ '\V{{{\w\+', '}}}', 'g' ], 
  \ [ '\V(', ')', 'g' ], 
  \ [ '\V[', ']', 'g' ], 
  \ [ '\V{', '}', 'g' ], 
  \ ]

" Surround text with delimiter. Optional "mode" param indicates 'visual'
" selection or a command-count for number of words to surround w/ delimiter
let g:surround_leader = "\<C-s>"
let g:surround_prompt_trigger = "\<C-e>"
let g:surround_{char2nr(g:surround_prompt_trigger)} = "\1Enter string: "
  \ . "\r.*\r\\=rc#SurroundOpenSubs(submatch(0))\1\r\1\r.*\r\\=rc#SurroundCloseSubs(submatch(0))\1"

exe 'map <expr>  ' . g:surround_leader . ' rc#Surround(v:count)'
exe 'imap <expr> ' . g:surround_leader . ' rc#Surround("insert")'
exe 'vmap <expr> ' . g:surround_leader . ' rc#Surround("visual")'


" SNIPPETS / SKELETONS

" " Directory where personal snippets are stored
" let g:UltiSnipsSnippetsDir = '~/.vim-personal/after/UltiSnips'
"
" " Define triggers
" let g:UltiSnipsExpandTrigger = "<M-Enter>"
" let g:UltiSnipsListSnippets = "<M-l>"
" let g:UltiSnipsJumpForwardTrigger  = "<M-Enter>"
" let g:UltiSnipsJumpBackwardTrigger = "<M-l>"
"
" " Automatically activate file type skeletons
" let skeletons#autoRegister = 1
"
" " Set directory where skeletons are stored
" let skeletons#skeletonsDir = '~/.skeletons/vim'


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

command! -bang -nargs=* FZFRelativeMru call rc#FZFRelativeMru()

" FZF mappings are all prefixed with ',/'
map <leader>/<space>   :Files 
map <leader>/~   :Files ~<CR>
 " 'f' for current file/folder (recursive)
map <leader>/f   :<C-u>Files <C-r>=rc#BufferFile(':h') . '/'<CR><CR>
map <leader>/<Enter> :Buffers<CR>
map <leader>/w   :Windows<CR>
 " '#' for color-code
map <leader>/3   :Colors<CR>
" lines in current buffer
map <leader>/.   :BLines<CR>
" lines in open buffers
map <leader>/=   :Lines<CR>
" 'l' for latest
map <leader>/<BS> :History<CR>  " file history
map <leader>/:   :History:<CR> " command history
map <leader>//   :History/<CR> " search history
" tags in current buffer
map <leader>/t   :BTags<CR>
" tags in open buffers
map <leader>/T   :Tags<CR>
map <leader>/'   :Marks<CR>
map <leader>/`   :Marks<CR>
map <leader>/L   :Locate 
map <leader>/s   :Snippets<CR>
map <leader>/C   :Commands<CR>
" 'k' for keymaps
map <leader>/k   :Maps<CR>
map <leader>/h   :Helptags<CR>
" 'P' for project
map <leader>/P   :GFiles<CR>
" 'd' for diff
map <leader>/d   :GFiles?<CR>
" 'm' for most recent
map <leader>/m   :FZFMru<CR>
" 'l' for latest
map <leader>/l   :FZFRelativeMru<CR>
" Requires Fugitive plugin:
map <leader>/c   :Commits!<CR>
" 'v' for versions
map <leader>/v   :BCommits!<CR>

" (Grep)
" Requires git
if executable('git')
  map <leader>/g   :GGrep<Space>
  map <leader>/G   :GGrep!<Space>
  map <leader>/<leader> :GGrep<CR>
endif
" Requires https://github.com/ggreer/the_silver_searcher
if executable('ag')
  map <leader>/g   :Ag<Space>
  map <leader>/G   :Ag!<Space>
  map <leader>/<leader> :Ag!<CR>
endif
" Requires https://github.com/BurntSushi/ripgrep
if executable('rg')
  map <leader>/g   :Rg<Space>
  map <leader>/G   :Rg!<Space>
  map <leader>/<leader> :Rg!<CR>
  " Requires ProjectRoot plugin
  map <leader>/p :call fzf#vim#grep(ProjectRootGuess(), 1, fzf#vim#with_preview('up:60%'), 1)<CR>
  " Recursively under current directory
  map <leader>/r :call fzf#vim#grep(<C-r>="g:rgAny . expand('%:p:h')"<CR>, 1, fzf#vim#with_preview('up:60%'), 1)<CR>
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
map <leader>go  :Gcheckout<Space>
map <leader>gwd :Gcd<Space>
map <leader>gr  :Gread<CR>
map <leader>gw  :Gwrite!<CR>
map <leader>gg  :Gwrite! \| Git commit<CR>
map <leader>gs  :Gstatus<CR>
map <leader>gc  :Git commit<CR>
map <leader>ga  :Git commit --amend<CR>
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

" ':GCheckout' will checkout git branch with command-line completion
command -complete=customlist,rc#ListBranches -nargs=1 Gcheckout !git checkout <args>


" SESSION MANAGER

" NOTE: see session autocommands in .vim/after/after.vim

" Set temp file location
let g:pickMeUpSessionDir = rc#MakeDir(s:TmpDir . 'sessions')

" ',ss' will prompt to save a named session
exe "map \<leader>ss :\<C-u>SaveSession " . g:pickMeUpSessionDir

" ',sr' will prompt to restore a named session
exe "map \<leader>sr :\<C-u>RestoreSession " . g:pickMeUpSessionDir

" ',sd' will prompt to delete a named session
exe "map \<leader>sd :\<C-u>DeleteSession " . g:pickMeUpSessionDir


" UNDO

if has('python3')
  let g:gundo_prefer_python3 = 1
endif

" ',uh' will Toggle interactive undo-history
map <leader>uh :GundoToggle<CR>

" Temporarily toggle conceal to fix undo behavior (using silent to hide syntax warnings)
map <silent> u :silent! call rc#ToggleConceal(0) \| silent! undo \| :silent! call rc#ToggleConceal(1)<CR>
map <silent> <C-r> :silent! call rc#ToggleConceal(0) \| silent! redo \| :silent! call rc#ToggleConceal(1)<CR>

" Prevent <Esc>u from accidentally inserting special character 'õ' in insert-mode
" (Use 'Ctrl-v,245' to insert 'õ' intentionally)
inoremap õ <C-\><C-n>u


" VISUALS

" NOTE: see conceal autocommands in .vim/after/after.vim

" Enable conceal syntax that would be redundant with font ligatures
" Set to true if using a font that supports programming ligatures
let g:font_ligatures_enabled = 0

" Don't conceal characters on line under cursor
" (this is flipped for focus-mode)
let g:enableConcealAtCursor = 0

" Set visual wrap indicator
set showbreak=⋯ " ↪

" Always show the sign column
set signcolumn=yes

" Do not show mode below the statusline
set noshowmode

" '/<Backspace>' will toggle search highlighting
map /<Backspace> :set hls!<CR>

" ',c' will toggle concealed text
map <leader>c :call rc#ToggleConceal()<CR>

" ',-' will toggle cursor line
map <leader>- :set cursorline!<CR>

" ',+' will toggle both
map <leader>+ :set cursorline! cursorcolumn!<CR>:call rc#ToggleConceal(!&cursorcolumn)<CR>


" FOLDING

" Initial fold regions based on syntax-rules
set foldmethod=syntax

" Have all folds open when a new file is loaded
set foldlevelstart=999

" Automatically open/close folds in insert-mode
set foldopen=all
set foldclose=all

" Customize how folded lines are displayed
set foldtext=rc#FoldText()


" STATUSLINE

" Use custom expression to build statusline
set statusline=%!rc_status#Status()

" ',vb' will toggle verbose statusline
map <silent> <leader>vb :call rc_status#ToggleVerboseStatus()<CR>

" FOCUS

" Increase width from default 80 characters
let g:goyo_width = 100

" Trigger custom-handlers when enabling/disabling focus-mode
autocmd! User GoyoEnter nested call rc#Focus()
autocmd! User GoyoLeave nested call rc#Blur()

" Toggle focus-mode
map <silent> <leader><leader> :Goyo<CR>

" Toggle focus highlighting
map <silent> <leader>h :Limelight!!<CR>


" STARTSCREEN

" Customize the start screen
let g:Startscreen_function = function('rc#StartScreen')


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

" Load plugins listed in /.vim/plugs
let s:plugins = readfile($HOME . '/.vim/plugs')
call plug#begin('~/.vim/bundle')
call map(s:plugins, {_, p -> rc#Plugin(p)})
call plug#end()

" POST-PLUGIN CONFIGURATION

" Set colorscheme
" dark: alduin antares apprentice hybrid_material iceberg OceanicNext PaperColor
" light: disciple earendel lightning
" base16: noctu
colorscheme custom_base16
call rc_status#SetDefaultStatusModeHLGroups()

" Source personal configurations, if present
if filereadable($HOME . '/personal/.vimrc')
  exe 'source ' . $HOME . '/personal/.vimrc'
endif

" Source work configurations, if present
if filereadable($HOME . '/business/.vimrc')
  exe 'source ' . $HOME . '/business/.vimrc'
endif

call rc#AutoAddMarkdownExtensionToNotes()
