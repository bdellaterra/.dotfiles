" File:         colors/denizen.vim
" Description:  Brian Dellaterra's Personal Vim Configuration
" Author:       Brian Dellaterra <github.com/bdellaterra>
" Version:      0.1.1
" License:      Copyright 2015-2017 Brian Dellaterra. This file is part of Vimbad.
"               Distributed under the terms of the GNU Lesser General Public License. See the file LICENSE or <http://www.gnu.org/licenses/>.

hi clear
syntax reset
let g:colors_name = "denizen"
if &background == "light"
	hi Boolean gui=NONE guifg=#707070 guibg=NONE
	hi ColorColumn gui=NONE guifg=NONE guibg=#f5f5f5
	hi Comment gui=NONE guifg=#969696 guibg=NONE
	hi Conceal gui=NONE guifg=#707070 guibg=NONE
	hi Conditional gui=NONE guifg=#4a4a4a guibg=NONE
	hi Constant gui=NONE guifg=#707070 guibg=NONE
	hi Cursor gui=reverse guifg=NONE guibg=NONE
	hi CursorColumn gui=NONE guifg=NONE guibg=#f5f5f5
	hi CursorLine gui=NONE guifg=NONE guibg=#f5f5f5
	hi CursorLineNr gui=NONE guifg=#969696 guibg=NONE
	hi DiffAdd gui=NONE guifg=NONE guibg=#f0fff0
	hi DiffChange gui=NONE guifg=NONE guibg=#f5f5f5
	hi DiffDelete gui=NONE guifg=NONE guibg=#fff0f0
	hi DiffText gui=NONE guifg=NONE guibg=#e3e3e3
	hi Directory gui=NONE guifg=#4a4a4a guibg=NONE
	hi Error gui=NONE guifg=NONE guibg=#fff0f0
	hi ErrorMsg gui=NONE guifg=NONE guibg=#fff0f0
	hi FoldColumn gui=NONE guifg=#c2c2c2 guibg=NONE
	hi Folded gui=NONE guifg=#969696 guibg=NONE
	hi Ignore gui=NONE guifg=NONE guibg=NONE
	hi IncSearch gui=NONE guifg=NONE guibg=#e3e3e3
	hi LineNr gui=NONE guifg=#c2c2c2 guibg=NONE
	hi MatchParen gui=NONE guifg=NONE guibg=#e3e3e3
	hi ModeMsg gui=NONE guifg=NONE guibg=NONE
	hi MoreMsg gui=NONE guifg=NONE guibg=NONE
	hi NonText gui=NONE guifg=#c2c2c2 guibg=NONE
	hi Normal gui=NONE guifg=#000000 guibg=#ffffff
	hi Number gui=NONE guifg=#707070 guibg=NONE
	hi Pmenu gui=NONE guifg=NONE guibg=#f5f5f5
	hi PmenuSbar gui=NONE guifg=NONE guibg=#ededed
	hi PmenuSel gui=NONE guifg=NONE guibg=#e3e3e3
	hi PmenuThumb gui=NONE guifg=NONE guibg=#dbdbdb
	hi Question gui=NONE guifg=NONE guibg=NONE
	hi Search gui=NONE guifg=NONE guibg=#ededed
	hi SignColumn gui=NONE guifg=#c2c2c2 guibg=NONE
	hi Special gui=NONE guifg=#707070 guibg=NONE
	hi SpecialKey gui=NONE guifg=#c2c2c2 guibg=NONE
	hi SpellBad gui=undercurl guisp=NONE guifg=NONE guibg=#fff0f0
	hi SpellCap gui=undercurl guisp=NONE guifg=NONE guibg=NONE
	hi SpellLocal gui=undercurl guisp=NONE guifg=NONE guibg=#f0fff0
	hi SpellRare gui=undercurl guisp=NONE guifg=NONE guibg=#ededed
	hi Statement gui=NONE guifg=#4a4a4a guibg=NONE
	hi StatusLine gui=NONE guifg=#262626 guibg=#ededed
	hi StatusLineNC gui=NONE guifg=#969696 guibg=#ededed
	hi StorageClass gui=NONE guifg=#4a4a4a guibg=NONE
	hi String gui=NONE guifg=#707070 guibg=NONE
	hi TabLine gui=NONE guifg=#969696 guibg=#ededed
	hi TabLineFill gui=NONE guifg=NONE guibg=#ededed
	hi TabLineSel gui=NONE guifg=#262626 guibg=#ededed
	hi Title gui=NONE guifg=#707070 guibg=NONE
	hi Todo gui=standout guifg=NONE guibg=NONE
	hi Type gui=NONE guifg=#4a4a4a guibg=NONE
	hi Underlined gui=NONE guifg=NONE guibg=NONE
	hi VertSplit gui=NONE guifg=#e3e3e3 guibg=NONE
	hi Visual gui=NONE guifg=NONE guibg=#e3e3e3
	hi VisualNOS gui=NONE guifg=NONE guibg=NONE
	hi WarningMsg gui=NONE guifg=NONE guibg=#fff0f0
	hi WildMenu gui=NONE guifg=NONE guibg=#d1d1d1
	hi lCursor gui=NONE guifg=NONE guibg=NONE
	hi Identifier gui=NONE guifg=NONE guibg=NONE
	hi PreProc gui=NONE guifg=NONE guibg=NONE
elseif &background == "dark"
	hi Boolean gui=NONE guifg=#90b6ee guibg=NONE
	hi ColorColumn gui=NONE guifg=NONE guibg=#816693
	hi Comment gui=NONE guifg=#f0a966 guibg=NONE
	hi Conceal gui=NONE guifg=#808080 guibg=NONE
	hi Conditional gui=NONE guifg=#ada6b5 guibg=NONE
	hi Constant gui=NONE guifg=#808080 guibg=NONE
	hi Cursor gui=reverse guifg=NONE guibg=NONE
	hi CursorColumn gui=NONE guifg=NONE guibg=#06687a
	hi CursorLine gui=NONE guifg=NONE guibg=#067184
	hi CursorLineNr gui=NONE guifg=#89d7d4 guibg=NONE
	hi DiffAdd gui=NONE guifg=NONE guibg=#052915
	hi DiffChange gui=NONE guifg=NONE guibg=#12161c
	hi DiffDelete gui=NONE guifg=NONE guibg=#430e0f
	hi DiffText gui=NONE guifg=#fafbbc guibg=#a23f34
	hi Directory gui=NONE guifg=#b89a93 guibg=NONE
	hi Error gui=NONE guifg=#ffffff guibg=#c8191f
	hi ErrorMsg gui=NONE guifg=#ffffff guibg=#c8191f
	hi FoldColumn gui=NONE guifg=#4b5391 guibg=#1b2841
	hi Folded gui=NONE guifg=#4b5391 guibg=#1b2841
	hi Ignore gui=NONE guifg=NONE guibg=NONE
	hi IncSearch gui=NONE guifg=#5b2f42 guibg=#edecb6
	hi LineNr gui=NONE guifg=#2493b2 guibg=NONE
	hi MatchParen gui=NONE guifg=NONE guibg=#232343
	hi ModeMsg gui=NONE guifg=NONE guibg=NONE
	hi MoreMsg gui=NONE guifg=NONE guibg=NONE
	hi NonText gui=NONE guifg=#658b9a guibg=#273d62
	hi Normal gui=NONE guifg=#eee8e8 guibg=#273d62
	hi Number gui=NONE guifg=#90b6ee guibg=NONE
	hi Pmenu gui=NONE guifg=#312f51 guibg=#00e0f0
	hi PmenuSbar gui=NONE guifg=NONE guibg=#09a3be
	hi PmenuSel gui=NONE guifg=#fafafa guibg=#112e5a
	hi PmenuThumb gui=NONE guifg=NONE guibg=#62f8f8
	hi Question gui=NONE guifg=NONE guibg=NONE
	hi Search gui=NONE guifg=#5b2f42 guibg=#b6bfb5
	hi SignColumn gui=NONE guifg=#616161 guibg=NONE
	hi Special gui=NONE guifg=#f2fdfd guibg=NONE
	hi SpecialKey gui=NONE guifg=#616161 guibg=NONE
	hi SpellBad gui=undercurl guisp=NONE guifg=#f9fdc9 guibg=#273d62
	hi SpellCap gui=undercurl guisp=NONE guifg=#f9fdc9 guibg=NONE
	hi SpellLocal gui=undercurl guisp=NONE guifg=#ffffff guibg=#273d62
	hi SpellRare gui=undercurl guisp=NONE guifg=#aad6a9 guibg=#273d62
	hi Statement gui=NONE guifg=#86e4e3 guibg=NONE
	hi StatusLine gui=NONE guifg=#a59aa7 guibg=#252028
	hi StatusLineNC gui=NONE guifg=#707070 guibg=#262626
	hi StorageClass gui=NONE guifg=#a3a5b8 guibg=NONE
	hi String gui=NONE guifg=#eddea6 guibg=NONE
	hi TabLine gui=bold,reverse guifg=#beb1b7 guibg=#4e090e
	hi TabLineFill gui=bold,reverse guifg=NONE guibg=#1f2137
	hi TabLineSel gui=bold,reverse guifg=#fafbbc guibg=#a23f34
	hi Title gui=NONE guifg=#b89a93 guibg=NONE
	hi Todo gui=standout guifg=NONE guibg=NONE
	hi Type gui=NONE guifg=#7893a5 guibg=NONE
	hi Underlined gui=NONE guifg=NONE guibg=NONE
	hi VertSplit gui=NONE guifg=#b79f95 guibg=NONE
	hi Visual gui=NONE guifg=#1c0f57 guibg=#defcfb
	hi VisualNOS gui=NONE guifg=NONE guibg=NONE
	hi WarningMsg gui=NONE guifg=NONE guibg=#c54a11
	hi WildMenu gui=NONE guifg=#373e3e guibg=#e1dd9d
	hi lCursor gui=NONE guifg=NONE guibg=NONE
	hi Identifier gui=NONE guifg=NONE guibg=NONE
	hi PreProc gui=NONE guifg=NONE guibg=NONE

	hi SpellCap ctermfg=7 ctermbg=0
	hi TabLine cterm=bold,reverse ctermfg=16 ctermbg=7
	hi TabLineFill cterm=NONE ctermfg=NONE ctermbg=16
	hi TabLineSel cterm=bold ctermfg=16 ctermbg=7
	hi Visual ctermfg=4 ctermbg=0
endif

