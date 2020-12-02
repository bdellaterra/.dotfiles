
" Automatically change to directory of the file being edited
set autochdir

" Make sure file is editable
set modifiable
set noreadonly

" Mappings

" ,l = list/locate sections
nmap <buffer> <leader>l :TOC<CR>:set ft=pandoc<CR>:set cursorline<CR>

" \] will insert markdown link delimiters
map \] :normal i[]()<CR><Left><Left>i
" (around selected text in visual mode)
vmap \] :normal `<i[<CR>:normal `>la]()<CR>i

" `1 will convert line to header-level 1, `2 for level 2, etc.
nmap <buffer> 1` :<C-u>call pandoc#keyboard#sections#ApplyHeader(1)<CR>
nmap <buffer> 2` :<C-u>call pandoc#keyboard#sections#ApplyHeader(2)<CR>
nmap <buffer> 3` :<C-u>call pandoc#keyboard#sections#ApplyHeader(3)<CR>
nmap <buffer> 4` :<C-u>call pandoc#keyboard#sections#ApplyHeader(4)<CR>
nmap <buffer> 5` :<C-u>call pandoc#keyboard#sections#ApplyHeader(5)<CR>
nmap <buffer> 6` :<C-u>call pandoc#keyboard#sections#ApplyHeader(6)<CR>
nmap <buffer> 7` :<C-u>call pandoc#keyboard#sections#ApplyHeader(7)<CR>
nmap <buffer> 8` :<C-u>call pandoc#keyboard#sections#ApplyHeader(8)<CR>
nmap <buffer> 9` :<C-u>call pandoc#keyboard#sections#ApplyHeader(9)<CR>
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


""""""""""""""""""""""""""""""""""""""""""""""""""

if !get(g:, 'vim_pandoc_syntax_exists', 0)
  let g:pandoc_syntax_exists = 1
  " Gradient Headers
  if exists('g:pandoc#syntax#conceal#use') && g:pandoc#syntax#conceal#use != 0
    if !exists('g:pandoc#syntax#conceal#blacklist') || index(g:pandoc#syntax#conceal#blacklist, 'atx') == -1
      syn match pandocAtxStart /#/ contained containedin=pandocAtxHeaderMark conceal cchar=█
      syn match pandocAtxStart /#\(#\)\@=/ contained containedin=pandocAtxHeaderMark conceal cchar=▓
      syn match pandocAtxStart /#\(##\)\@=/ contained containedin=pandocAtxHeaderMark conceal cchar=▒
      syn match pandocAtxStart /#\(###\+\)\@=/ contained containedin=pandocAtxHeaderMark conceal cchar=░
    endif
  endif

  " Conceal escaped quotes
  syn match pandocSlashDoubleQuote /\\"/ conceal cchar="
  syn match pandocSlashSingleQuote /\\'/ conceal cchar='

  " adjust styling highlights
  hi! link pandocStrong Statement
  hi! link pandocStrikeout Comment
  hi! link pandocStrikeoutMark WarningMsg

  " Prevent false emphasis syntax region that can lead to runaway highlighting
  if !(get(g:, 'allowPandocEmphasis', 0) || get(b:, 'allowPandocEmphasis', 0))
    syn clear pandocEmphasis
    syn clear pandocEmphasisInStrong
    syn match pandocEmphasisDelimiter /\*/ conceal
  endif

  " Highlight markdown references without label the same as normal references 
  hi! link pandocNoLabel Statement

  " Highlight links with spaces consistently
  hi! link htmlTagN Statement
endif

set conceallevel=2
