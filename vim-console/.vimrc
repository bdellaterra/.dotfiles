" *** Inital Confiuration ****************************************************

" PLUGIN MANAGER

" Auto-install plug.vim
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


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
let s:TmpDir = $HOME . '/tmp/vim'
if !isdirectory(s:TmpDir) && exists('*mkdir')
    try | call mkdir(s:TmpDir, 'p') | endtry
endif

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

" Faster updates
set updatetime=1000

" Reduce timeout for operator-pending mode
set timeout timeoutlen=500 ttimeoutlen=500


" GUI

" Don't show the toolbar/icons
set guioptions-=T

" Share system clipboard with unnamed register for copy/paste
set clipboard=unnamed,unnamedplus


" TERMINAL

" Fix arrow keys
" (See https://unix.stackexchange.com/questions/29907/how-to-get-vim-to-work-with-tmux-properly)
" (See https://stackoverflow.com/questions/8813855/in-vim-how-can-i-make-esc-and-arrow-keys-work-in-insert-mode)
if &term =~ '^screen' || has('Mac')
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
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
" (See https://vi.stackexchange.com/questions/3379/cursor-shape-under-vim-tmux)
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
else
    let &t_SI = "\e[5 q"
    let &t_EI = "\e[2 q"
endif

" Improve console colors
if $TERM =~ '256color' || $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif


" FILE MANAGER

" Replace default file manager when viewing directories
let g:ranger_replace_netrw = 1

" Set temp file location
let g:ranger_choice_file = s:TmpDir . '/RangerChosenFile'

" Don't use plugin mappings
let g:ranger_map_keys = 0

map <leader>. :Ranger<CR>
map <leader>r :RangerWorkingDirectory<CR> " working-dir is usually project root


" BUFFERS

" Show buffers if two or more are open
let g:buftabline_show = 2

" Show buffer numbers
let g:buftabline_numbers = 1

" Show separators between buffer names
let g:buftabline_separators = 0

" Helper function to control behavior of the equals key:
function! s:EditBufferOrReindent(...)
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
" Number zero signifies the althernate buffer. (See :help alternate-file)
" Otherwise the default re-indent behavior is used.
noremap <expr>= <SID>EditBufferOrReindent(v:count)
noremap 0= :<C-u>confirm buffer #<CR>  " Vim won't pass zero-counts to mappings

" '-=' will delete current buffer or # buffer number via command-count
nnoremap -= :<C-u>exe (v:count ? v:count : '') . 'bdelete'<CR>
nnoremap 0-= :<C-u>confirm bdelete #<CR>

" '+=' will prompt for editing a file with filename needing to be specified.
" Path will be same as the current buffer or # buffer via command-count
nnoremap += :<C-u>edit <C-r>=expand((v:count ? '#'.v:count : '%') . ':p:h') . '/'<CR>

" '=]' will switch to previous buffer, or command-count buffers back
nnoremap =] :<C-u>exe (v:count ? v:count : '') . 'bnext'<CR>

" '=[' will switch to previous buffer, or command-count buffers back
nnoremap =[ :<C-u>exe (v:count ? v:count : '') . 'bprev'<CR>


" SESSION MANAGER

" Set temp file location
let g:pickMeUpSessionDir = s:TmpDir


" UNDO

" Toggle interactive undo-history
map <leader>uh :GundoToggle<CR>


" ALIGNMENT

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)"


" Completion

" Show completion menu even if it has one item
set completeopt+=menuone

" Do not auto-select completion option
set completeopt+=noselect

" Shut off completion messages and beeps
set shortmess+=c
set belloff+=ctrlg

" Auto-complete without hitting <Tab>
let g:mucomplete#enable_auto_at_startup = 1


" Fuzzy-Find
" (All commands are prefized with <leader>/)

map <leader>/p   :Files 
map <leader>/~   :Files ~<CR>
map <leader>/.   :Files ./<CR>
map <leader>/r   :exe 'Files ' . ProjectRootGuess()<CR> " requires ProjectRoot plugin
map <leader>/gf  :GFiles<CR>
map <leader>/gs  :GFiles?<CR>
map <leader>/b   :Buffers<CR>
map <leader>/cs  :Colors<CR>
map <leader>/a   :Ag<CR> " (See https://github.com/ggreer/the_silver_searcher)
map <leader>/gr  :Rg<CR> " (See https://github.com/BurntSushi/ripgrep)
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


" *** Delayed Configuration **************************************************

" PLUGINS

" Load plugins listed in /.vim/plugs
" (Order can matter, '#' style comments, empty lines skipped)
let s:plugins = readfile($HOME . '/.vim/plugs')
function! s:plugin(plug)
    let [locator, options] = matchlist(a:plug, '\v^([^# ]*)\s*(\{[^}#]*\})?')[1:2]
    if len(locator)
        call call('plug#', len(options) ? [locator, eval(options)] : [locator])
    end
endfunction
call plug#begin('~/.vim/bundle')
call map(s:plugins, {_, p -> s:plugin(p)})
call plug#end()


" POST-PLUGIN CONFIGURATION

" Set colorscheme
colorscheme apprentice


