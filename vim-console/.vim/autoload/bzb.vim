if &cp || exists("g:loaded_bzb_plugin")
 finish
endif
let g:loaded_bzb_plugin = "v01"
let s:keepcpo        = &cpo
set cpo&vim

function bzb#BZBCommand(...)
  let g:target = get(a:000, 0, fnamemodify(expand('%'), ':p:h'))
  let project_root = ProjectRootGuess()
  let base_dir = fnameescape(isdirectory(project_root) ? project_root : getcwd())
  if !exists('g:BZB_Command')
    let g:BZB_Command = 'bzb -c -as -al -ah'
  endif
  let g:keybinds = len($BZB_BIND) ? "BZB_BIND='" . $BZB_BIND . "' " : ''
  let g:cmd = g:keybinds . g:BZB_Command . ' -E -bd=' . base_dir . ' ' . fnameescape(g:target)
  return g:cmd
endfunction

function bzb#BZB(...)
  let save_lazyredraw = &lazyredraw
  set lazyredraw
  let target = get(a:000, 0, fnamemodify(expand('%'), ':p:h'))
  exe '!' . bzb#BZBCommand(target)
  silent! let g:BZB_Targets=readfile(expand('$HOME') . '/.bzb/selection')
  exe 'argadd ' . join(map(g:BZB_Targets, 'fnameescape(v:val)'), ' ')
  if len(g:BZB_Targets) | exe 'edit ' . g:BZB_Targets[0] | endif
  let &lazyredraw = save_lazyredraw
  redraw!
endfunction
