
set background=dark
hi! clear

if exists("syntax_on")
  syntax reset
endif

highlight DiffAdd        ctermfg=0    ctermbg=2
highlight DiffChange     ctermfg=0    ctermbg=3
highlight DiffDelete     ctermfg=0    ctermbg=1
highlight DiffText              ctermbg=11  ctermfg=16

highlight Visual         ctermfg=NONE ctermbg=0 cterm=inverse

highlight Search         ctermfg=0    ctermbg=11

if &background == "light"
  highlight LineNr       ctermfg=7
  highlight Comment      ctermfg=7
  highlight ColorColumn  ctermfg=8    ctermbg=7
  highlight Folded       ctermfg=8    ctermbg=7
  highlight FoldColumn   ctermfg=8    ctermbg=7
  highlight Pmenu        ctermfg=0    ctermbg=7
  highlight PmenuSel     ctermfg=7    ctermbg=0
  highlight SpellCap     ctermfg=8    ctermbg=7
  highlight StatusLine   ctermfg=0    ctermbg=7    cterm=bold
  highlight StatusLineNC ctermfg=8    ctermbg=7    cterm=NONE
  highlight VertSplit    ctermfg=8    ctermbg=7    cterm=NONE
  highlight SignColumn                ctermbg=7
else
  highlight LineNr       ctermfg=8    ctermbg=0
  highlight Comment      ctermfg=8
  highlight ColorColumn  ctermfg=7    ctermbg=8
  highlight Folded       ctermfg=13    ctermbg=0
  highlight FoldColumn   ctermfg=7    ctermbg=8
  highlight Pmenu        ctermfg=15   ctermbg=5
  highlight PmenuSel     ctermfg=5    ctermbg=15
  highlight SpellCap     ctermfg=7    ctermbg=8
  highlight StatusLine   ctermfg=15   ctermbg=4    cterm=bold
  highlight StatusLineNC ctermfg=7    ctermbg=5    cterm=NONE
  highlight VertSplit    ctermfg=7    ctermbg=8    cterm=NONE
  highlight SignColumn                ctermbg=8
endif



hi CursorLine          ctermbg=0     cterm=NONE
hi Conceal             ctermfg=6     ctermbg=NONE
hi ErrorMsg            ctermfg=15    ctermbg=1
hi IncSearch           ctermfg=16     ctermbg=4
hi Search              ctermfg=16     ctermbg=14
hi Title               ctermfg=3     cterm=bold

hi! link CursorColumn  CursorLine
hi! link SignColumn    LineNr
hi! link WildMenu      Visual
hi! link FoldColumn    SignColumn
hi! link WarningMsg    ErrorMsg
hi! link MoreMsg       Title
hi! link Question      MoreMsg
hi! link ModeMsg       MoreMsg
hi! link TabLineFill   StatusLineNC
hi! link SpecialKey    NonText

hi Type            ctermfg=10
hi Statement       ctermfg=3   cterm=bold

highlight BufTabLineCurrent        ctermfg=15 ctermbg=4
highlight BufTabLineActive         ctermfg=15 ctermbg=13
highlight BufTabLineHidden         ctermfg=13 ctermbg=5

