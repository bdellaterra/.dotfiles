set background=dark
hi! clear

if exists("syntax_on")
  syntax reset
endif

highlight DiffAdd        ctermfg=0    ctermbg=2
highlight DiffChange     ctermfg=0    ctermbg=3
highlight DiffDelete     ctermfg=0    ctermbg=1
highlight DiffText       ctermbg=11  ctermfg=16

highlight Visual         ctermfg=15 ctermbg=6

highlight Search         ctermfg=11    ctermbg=0   cterm=inverse

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
  highlight Folded       ctermfg=13   ctermbg=0
  highlight FoldColumn   ctermfg=13   ctermbg=5
  highlight Pmenu        ctermfg=15   ctermbg=5
  highlight PmenuSel     ctermfg=5    ctermbg=15
  highlight SpellCap     ctermfg=7    ctermbg=8
  highlight VertSplit    ctermfg=7    ctermbg=8    cterm=NONE
  highlight SignColumn                ctermbg=8
  highlight Underlined   ctermfg=12                cterm=underline
endif

hi Conceal                   ctermfg=6             ctermbg=NONE
hi CursorLine                ctermbg=0             cterm=NONE
hi Directory                 ctermfg=10            cterm=bold
hi ErrorMsg                  ctermfg=15 ctermbg=1
hi WarningMsg                ctermfg=15 ctermbg=9  cterm=bold
hi IncSearch                 ctermfg=16 ctermbg=4
hi MoreMsg                   ctermfg=11            cterm=bold
hi PMenuSbar                 ctermfg=15 ctermbg=7
hi PreProc                   ctermfg=12
hi Search                    ctermfg=16 ctermbg=14
hi Special                   ctermfg=14            cterm=bold
hi Statement                 ctermfg=11            cterm=NONE
hi TabLine                   ctermfg=15 ctermbg=6  cterm=NONE
hi Title                     ctermfg=3             cterm=bold
hi Type                      ctermfg=10

highlight StatusLine         ctermfg=15 ctermbg=4  cterm=NONE
highlight StatusLineNC       ctermfg=4  ctermbg=15 cterm=inverse 
highlight StatusLineTerm     ctermfg=15 ctermbg=14 cterm=NONE 
highlight StatusLineTermNC   ctermfg=15 ctermbg=6  cterm=NONE 
highlight BufTabLineCurrent  ctermfg=15 ctermbg=4
highlight BufTabLineActive   ctermfg=15 ctermbg=13
highlight BufTabLineHidden   ctermfg=13 ctermbg=5

hi! link CursorColumn  CursorLine
hi! link SignColumn    LineNr
hi! link WildMenu      Visual
hi! link ModeMsg       MoreMsg
hi! link TabLineFill   StatusLineNC
hi! link SpecialKey    NonText

hi clear Question
hi! link Question      MoreMsg

let g:colors_name = 'custom_base16'
