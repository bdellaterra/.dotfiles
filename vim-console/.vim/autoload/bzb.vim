if &cp || exists("g:loaded_bzb_plugin")
 finish
endif
let g:loaded_bzb_plugin = "v01"
let s:keepcpo        = &cpo
set cpo&vim

function bzb#BZB()
  if !exists('g:BZB_Command')
    let g:BZB_Command = 'bzb -c -as -al'
  endif
  return g:BZB_Command
endfunction
