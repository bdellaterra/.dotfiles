
" Mappings
nmap <buffer> <leader>l :TOC<CR>:set ft=pandoc<CR>:set cursorline<CR> " l = list/locate sections
nmap <buffer> ` <Plug>(pandoc-keyboard-apply-header)
nmap <buffer> 0` <Plug>(pandoc-keyboard-remove-header)
nmap <buffer> <leader>i <Plug>(pandoc-keyboard-toggle-emphasis)
vmap <buffer> <leader>i <Plug>(pandoc-keyboard-toggle-emphasis)
nmap <buffer> <leader>b <Plug>(pandoc-keyboard-toggle-strong)
vmap <buffer> <leader>b <Plug>(pandoc-keyboard-toggle-strong)
nmap <buffer> <leader>' <Plug>(pandoc-keyboard-toggle-verbatim)
vmap <buffer> <leader>' <Plug>(pandoc-keyboard-toggle-verbatim)
nmap <buffer> <leader>~ <Plug>(pandoc-keyboard-toggle-strikeout)
vmap <buffer> <leader>~ <Plug>(pandoc-keyboard-toggle-strikeout)
nmap <buffer> <leader>^ <Plug>(pandoc-keyboard-toggle-superscript)
vmap <buffer> <leader>^ <Plug>(pandoc-keyboard-toggle-superscript)
nmap <buffer> <leader>_ <Plug>(pandoc-keyboard-toggle-subscript)
vmap <buffer> <leader>_ <Plug>(pandoc-keyboard-toggle-subscript)

" Default Mappings
" <localleader>hn    " move to next header [n]
" <localleader>hb    " move to previous header [n]
" <localleader>hh    " go to current header [n]
" <localleader>hp    " go to current header's parent [n]
" <localleader>hsn   " move to next sibling header [n]
" <localleader>hsb   " move to previous sibling header [n]
" <localleader>hcf   " move fo first child header [n]
" <localleader>hcl   " move to last child header [n]
" <localleader>hcn   " move to [count] nth child header [n]
" ]]                 " [count] sections forward (like <localleader>hn) [n]
" [[                 " [count] sections backwards [n]
" ][                 " [count] move to the next section end [n]
" []                 " [count] move to the previous section end [n]
" aS                 " select a section, including header [vo]
" iS                 " select a section, excluding header [vo]
" <localleader>nr    " insert a ref definition after this paragraph [n]
" <localleader>rg    " go to reference definition [n]
" <localleader>rb    " go back to reference label [n]
" <localleader>gl    " go to current link in current window
" <localleader>sl    " go to current link in split window
" <localleader>gb    " go back from link
" <localleader>gB    " go back from link to the previous file
" <localleader>ln    " move to next list item [n]
" <localleader>lp    " move to previous list item [n]
" <localleader>ll    " move to the current list item [n]
" <localleader>llp   " move to parent of the current list item [n]
" <localleader>lsn   " move to the next list item sibling [n]
" <localleader>lsp   " move to the previous list item sibling [n]
" <localleader>lcf   " move to the first list item child [n]
" <localleader>lcl   " move to the last list item child [n]
" <localleader>lcn   " move to the [count] nth list item child [n]

