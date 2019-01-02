" don't worry about backwards-compatibility with vi 
set nocompatible

" manage plugins
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/bundle')
call map(readfile($HOME . '/.vim/plugs'), {_, p -> plug#(p)})
call plug#end()

" Fix arrow keys
" ref: https://unix.stackexchange.com/questions/29907/how-to-get-vim-to-work-with-tmux-properly
" ref: https://stackoverflow.com/questions/8813855/in-vim-how-can-i-make-esc-and-arrow-keys-work-in-insert-mode
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

" improve console colors
if $TERM =~ "256color" || $COLORTERM == "gnome-terminal"
    set t_Co=256
endif

" Specify the mapleader for Vim mappings.
let mapleader = ','

" Disable backwards-compatibility with Vi. (ancestor of Vim)
set cpoptions&vim

" disable modelines for better security
set modelines=0

" Allow backspacing over everything.
set backspace=indent,eol,start

" Display most of a last line that doesn't fit in the window.
set display=lastline

" Auto-save when opening/changing buffers.
set autowriteall

" Set directory where temporary files can be stored.
let s:TmpDir = $HOME . "/tmp/vim"
if !isdirectory(s:TmpDir)
    try | call mkdir(s:TmpDir) | endtry
endif

" Keep swap/backup/undo files from cluttering the working directory.
set nobackup
exe 'set directory=' . s:TmpDir
set undofile
exe 'set undodir=' . s:TmpDir

" Disable beep and visual flash alerts.
autocmd VimEnter * set vb t_vb=

" Clear the screen so there are no initial status messages.
autocmd VimEnter * silent! redraw!

" Don't automatically wrap lines.
set formatoptions-=t

" Ignore case in searches using only lowercase letters.
set ignorecase smartcase

" Keep a long command history.
set history=100

" Have all folds open when a new file is loaded.
set foldlevelstart=999

" Prevent "Hit enter to continue" message.
set shortmess+=T
" Further reduce prompts by increasing the height of the command line.
set cmdheight=1

" Set tabbing behavior.
set shiftwidth=4
set tabstop=4
set expandtab

" Always show status line
set laststatus=2

" Don't show the toolbar/icons
set guioptions-=T

" set colorscheme
colorscheme apprentice


" FILE MANAGER

" replace default file manager when viewing directories
let g:ranger_replace_netrw = 1

" set temp file location
let g:ranger_choice_file = s:TmpDir . '/RangerChosenFile'

" don't use plugin mappings
let g:ranger_map_keys = 0

map <leader>. :Ranger<CR>
map <leader>e :RangerWorkingDirectory<CR>


" BUFFERS

" Show buffers if two or more are open.
let g:buftabline_show = 1

" Show buffer numbers.
let g:buftabline_numbers = 1

" Show separators between buffer names.
let g:buftabline_separators = 0


" SESSIONS

" set temp file location
let g:prosession_dir = s:TmpDir

" update tmux window titles to session folder name
let g:prosession_tmux_title = 1
let g:prosession_tmux_title_format = "@@@"

" autmatically load session on startup, using "default" if none exists
let g:prosession_on_startup = 1

