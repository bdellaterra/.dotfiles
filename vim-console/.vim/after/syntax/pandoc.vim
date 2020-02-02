
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

" False emphasis can be problemaic with markdown generated from html
if exists('b:pandocNoEmphasis') && b:pandocNoEmphasis == 1
  syn clear pandocEmphasis
  syn clear pandocEmphasisInStrong
endif

" Highlight markdown references without label the same as normal references 
hi! link pandocNoLabel Statement

" Highlight links with spaces consistently
hi! link htmlTagN Statement
