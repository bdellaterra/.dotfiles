if &cp || exists("g:loaded_bzb_plugin")
 finish
endif
let g:loaded_bzb_plugin = "v01"
let s:keepcpo        = &cpo
set cpo&vim

function bzb#BZB(...)
  let target = get(a:000, 0, fnamemodify(expand('%'), ':p:h'))
  let project_root = ProjectRootGuess()
  let base_dir = fnameescape(isdirectory(project_root) ? project_root : getcwd())
  if !exists('g:BZB_Command')
    let g:BZB_Command = 'bzb -c -as -al -ah'
  endif
  return g:BZB_Command . ' -E -bd=' . base_dir . ' ' . target
endfunction
