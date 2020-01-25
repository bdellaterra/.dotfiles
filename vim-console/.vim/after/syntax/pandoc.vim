
" Gradient Headers
if exists('g:pandoc#syntax#conceal#use') && g:pandoc#syntax#conceal#use != 0
  if !exists('g:pandoc#syntax#conceal#blacklist') || index(g:pandoc#syntax#conceal#blacklist, 'atx') == -1
    syn match pandocAtxStart /#/ contained containedin=pandocAtxHeaderMark conceal cchar=█
    syn match pandocAtxStart /#\(#\)\@=/ contained containedin=pandocAtxHeaderMark conceal cchar=▓
    syn match pandocAtxStart /#\(##\)\@=/ contained containedin=pandocAtxHeaderMark conceal cchar=▒
    syn match pandocAtxStart /#\(###\+\)\@=/ contained containedin=pandocAtxHeaderMark conceal cchar=░
  endif
endif

" adjust styling highlights
hi! link pandocStrong Statement
hi! link pandocStrikeout Comment
hi! link pandocStrikeoutMark WarningMsg

" Highlight markdown references without label the same as normal references 
hi! link pandocNoLabel Statement

" Highlight links with spaces consistently
hi! link htmlTagN Statement
