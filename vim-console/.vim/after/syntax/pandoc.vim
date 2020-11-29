" Modified from https://github.com/vim-pandoc/vim-pandoc-syntax/blob/master/syntax/pandoc.vim
scriptencoding utf-8

" cchars used in conceal rules {{{2
" utf-8 defaults (preferred)
if &encoding ==# 'utf-8'
    let s:cchars = {
                \'newline': '↵',
                \'image': '▨',
                \'super': 'ⁿ',
                \'sub': 'ₙ',
                \'strike': 'x̶',
                \'atx': '§',
                \'codelang': 'λ',
                \'codeend': '—',
                \'abbrev': '→',
                \'footnote': '†',
                \'definition': ' ',
                \'li': '•',
                \'html_c_s': '‹',
                \'html_c_e': '›'}
else
    " ascii defaults
    let s:cchars = {
                \'newline': ' ',
                \'image': 'i',
                \'super': '^',
                \'sub': '_',
                \'strike': '~',
                \'atx': '#',
                \'codelang': 'l',
                \'codeend': '-',
                \'abbrev': 'a',
                \'footnote': 'f',
                \'definition': ' ',
                \'li': '*',
                \'html_c_s': '+',
                \'html_c_e': '+'}
endif
" }}}2

" Titleblock: {{{2
syn region pandocTitleBlock start=/\%^%/ end=/\n\n/ contains=pandocReferenceLabel,pandocReferenceURL,pandocNewLine
syn match pandocTitleBlockMark /%\ / contained containedin=pandocTitleBlock,pandocTitleBlockTitle conceal
syn match pandocTitleBlockTitle /\%^%.*\n/ contained containedin=pandocTitleBlock
" }}}2

" Blockquotes: {{{2
syn match pandocBlockQuote /^\s\{,3}>.*\n\(.*\n\@1<!\n\)*/ contains=@Spell,pandocEmphasis,pandocStrong,pandocPCite,pandocSuperscript,pandocSubscript,pandocStrikeout,pandocUListItem,pandocNoFormatted,pandocAmpersandEscape,pandocLaTeXInlineMath,pandocEscapedDollar,pandocLaTeXCommand,pandocLaTeXMathBlock,pandocLaTeXRegion skipnl
syn match pandocBlockQuoteMark /\_^\s\{,3}>/ contained containedin=pandocEmphasis,pandocStrong,pandocPCite,pandocSuperscript,pandocSubscript,pandocStrikeout,pandocUListItem,pandocNoFormatted
" }}}2

" Code Blocks: {{{2
syn region pandocCodeBlockInsideIndent   start=/\(\(\d\|\a\|*\).*\n\)\@<!\(^\(\s\{8,}\|\t\+\)\).*\n/ end=/.\(\n^\s*\n\)\@=/ contained
" }}}2

" Links: {{{2

" Base: {{{3
syn region pandocReferenceLabel matchgroup=pandocOperator start=/!\{,1}\\\@<!\^\@<!\[/ skip=/\(\\\@<!\]\]\@=\|`.*\\\@<!].*`\)/ end=/\\\@<!\]/ keepend display
syn region pandocReferenceURL matchgroup=pandocOperator start=/\]\@1<=(/ end=/)/ keepend conceal
" let's not consider "a [label] a" as a label, remove formatting - Note: breaks implicit links
syn match pandocNoLabel /\]\@1<!\(\s\{,3}\|^\)\[[^\[\]]\{-}\]\(\s\+\|$\)[\[(]\@!/ contains=pandocPCite
syn match pandocLinkTip /\s*".\{-}"/ contained containedin=pandocReferenceURL contains=@Spell,pandocAmpersandEscape display
exe 'syn match pandocImageIcon /!\[\@=/ display conceal cchar=' . s:cchars['image']
" }}}3

" Definitions: {{{3
syn region pandocReferenceDefinition start="!\=\[\%(\_[^]]*]\%( \=[[(]\)\)\@=" end="\]\%( \=[[(]\)\@=" keepend
syn match pandocReferenceDefinitionLabel /\[\zs.\{-}\ze\]:/ contained containedin=pandocReferenceDefinition display
syn match pandocReferenceDefinitionAddress /:\s*\zs.*/ contained containedin=pandocReferenceDefinition
syn match pandocReferenceDefinitionTip /\s*".\{-}"/ contained containedin=pandocReferenceDefinition,pandocReferenceDefinitionAddress contains=@Spell,pandocAmpersandEscape
" }}}3

" Automatic_links: {{{3
syn match pandocAutomaticLink /<\(https\{0,1}.\{-}\|[A-Za-z0-9!#$%&'*+\-/=?^_`{|}~.]\{-}@[A-Za-z0-9\-]\{-}\.\w\{-}\)>/ contains=NONE
" }}}3

" }}}2

" Citations: {{{2
" parenthetical citations
syn match pandocPCite "\^\@<!\[[^\[\]]\{-}-\{0,1}@[[:alnum:]_][[:digit:][:lower:][:upper:]_:.#$%&\-+?<>~/]*.\{-}\]" contains=pandocEmphasis,pandocStrong,pandocLatex,pandocCiteKey,@Spell,pandocAmpersandEscape display
" in-text citations with location
syn match pandocICite "@[[:alnum:]_][[:digit:][:lower:][:upper:]_:.#$%&\-+?<>~/]*\s\[.\{-1,}\]" contains=pandocCiteKey,@Spell display
" cite keys
syn match pandocCiteKey /\(-\=@[[:alnum:]_][[:digit:][:lower:][:upper:]_:.#$%&\-+?<>~/]*\)/ containedin=pandocPCite,pandocICite contains=@NoSpell display
syn match pandocCiteAnchor /[-@]/ contained containedin=pandocCiteKey display
syn match pandocCiteLocator /[\[\]]/ contained containedin=pandocPCite,pandocICite
" }}}2

" Text Styles: {{{2

" Emphasis: {{{3
syn region pandocEmphasis matchgroup=pandocOperator start=/\\\@1<!\(\_^\|\s\|[[:punct:]]\)\@<=\*\S\@=/ skip=/\(\*\*\|__\)/ end=/\*\([[:punct:]]\|\s\|\_$\)\@=/ contains=@Spell,pandocNoFormattedInEmphasis,pandocLatexInlineMath,pandocAmpersandEscape concealends
syn region pandocEmphasis matchgroup=pandocOperator start=/\\\@1<!\(\_^\|\s\|[[:punct:]]\)\@<=_\S\@=/ skip=/\(\*\*\|__\)/ end=/\S\@1<=_\([[:punct:]]\|\s\|\_$\)\@=/ contains=@Spell,pandocNoFormattedInEmphasis,pandocLatexInlineMath,pandocAmpersandEscape concealends
" }}}3

" Strong: {{{3
syn region pandocStrong matchgroup=pandocOperator start=/\(\\\@<!\*\)\{2}/ end=/\(\\\@<!\*\)\{2}/ contains=@Spell,pandocNoFormattedInStrong,pandocLatexInlineMath,pandocAmpersandEscape concealends
syn region pandocStrong matchgroup=pandocOperator start=/__/ end=/__/ contains=@Spell,pandocNoFormattedInStrong,pandocLatexInlineMath,pandocAmpersandEscape concealends
" }}}3

" Strong Emphasis: {{{3
syn region pandocStrongEmphasis matchgroup=pandocOperator start=/\*\{3}\(\S[^*]*\(\*\S\|\n[^*]*\*\S\)\)\@=/ end=/\S\@<=\*\{3}/ contains=@Spell,pandocAmpersandEscape concealends
syn region pandocStrongEmphasis matchgroup=pandocOperator start=/\(___\)\S\@=/ end=/\S\@<=___/ contains=@Spell,pandocAmpersandEscape concealends
" }}}3

" Mixed: {{{3
syn region pandocStrongInEmphasis matchgroup=pandocOperator start=/\*\*/ end=/\*\*/ contained containedin=pandocEmphasis contains=@Spell,pandocAmpersandEscape concealends
syn region pandocStrongInEmphasis matchgroup=pandocOperator start=/__/ end=/__/ contained containedin=pandocEmphasis contains=@Spell,pandocAmpersandEscape concealends
syn region pandocEmphasisInStrong matchgroup=pandocOperator start=/\\\@1<!\(\_^\|\s\|[[:punct:]]\)\@<=\*\S\@=/ skip=/\(\*\*\|__\)/ end=/\S\@<=\*\([[:punct:]]\|\s\|\_$\)\@=/ contained containedin=pandocStrong contains=@Spell,pandocAmpersandEscape concealends
syn region pandocEmphasisInStrong matchgroup=pandocOperator start=/\\\@<!\(\_^\|\s\|[[:punct:]]\)\@<=_\S\@=/ skip=/\(\*\*\|__\)/ end=/\S\@<=_\([[:punct:]]\|\s\|\_$\)\@=/ contained containedin=pandocStrong contains=@Spell,pandocAmpersandEscape concealends
" }}}3

" Inline Code: {{{3
" Using single back ticks
syn region pandocNoFormatted matchgroup=pandocOperator start=/\\\@<!`/ end=/\\\@<!`/ nextgroup=pandocNoFormattedAttrs concealends
syn region pandocNoFormattedInEmphasis matchgroup=pandocOperator start=/\\\@<!`/ end=/\\\@<!`/ nextgroup=pandocNoFormattedAttrs contained concealends
syn region pandocNoFormattedInStrong matchgroup=pandocOperator start=/\\\@<!`/ end=/\\\@<!`/ nextgroup=pandocNoFormattedAttrs contained concealends

syn region pandocNoFormatted matchgroup=pandocOperator start=/\\\@<!``/ end=/\\\@<!``/ nextgroup=pandocNoFormattedAttrs concealends
syn region pandocNoFormattedInEmphasis matchgroup=pandocOperator start=/\\\@<!``/ end=/\\\@<!``/ nextgroup=pandocNoFormattedAttrs contained concealends
syn region pandocNoFormattedInStrong matchgroup=pandocOperator start=/\\\@<!``/ end=/\\\@<!``/ nextgroup=pandocNoFormattedAttrs contained concealends
syn match pandocNoFormattedAttrs /{.\{-}}/ contained
" }}}3

" Subscripts: {{{3
syn region pandocSubscript start=/\~\(\([[:graph:]]\(\\ \)\=\)\{-}\~\)\@=/ end=/\~/ keepend
exe 'syn match pandocSubscriptMark /\~/ contained containedin=pandocSubscript conceal cchar='.s:cchars['sub']
" }}}3

" Superscript: {{{3
syn region pandocSuperscript start=/\^\(\([[:graph:]]\(\\ \)\=\)\{-}\^\)\@=/ skip=/\\ / end=/\^/ keepend
exe 'syn match pandocSuperscriptMark /\^/ contained containedin=pandocSuperscript conceal cchar='.s:cchars['super']
" }}}3

" Strikeout: {{{3
syn region pandocStrikeout start=/\~\~/ end=/\~\~/ contains=@Spell,pandocAmpersandEscape keepend
exe 'syn match pandocStrikeoutMark /\~\~/ contained containedin=pandocStrikeout conceal cchar='.s:cchars['strike']
" }}}3

" }}}2

" Headers: {{{2
syn match pandocAtxHeader /\(\%^\|<.\+>.*\n\|^\s*\n\)\@<=#\{1,6}.*\n/ contains=pandocEmphasis,pandocStrong,pandocNoFormatted,pandocLaTeXInlineMath,pandocEscapedDollar,@Spell,pandocAmpersandEscape,pandocReferenceLabel,pandocReferenceURL display
syn match pandocAtxHeaderMark /\(^#\{1,6}\|\\\@<!#\+\(\s*.*$\)\@=\)/ contained containedin=pandocAtxHeader
exe 'syn match pandocAtxStart /#/ contained containedin=pandocAtxHeaderMark conceal cchar='.s:cchars['atx']
syn match pandocSetexHeader /^.\+\n[=]\+$/ contains=pandocEmphasis,pandocStrong,pandocNoFormatted,pandocLaTeXInlineMath,pandocEscapedDollar,@Spell,pandocAmpersandEscape
syn match pandocSetexHeader /^.\+\n[-]\+$/ contains=pandocEmphasis,pandocStrong,pandocNoFormatted,pandocLaTeXInlineMath,pandocEscapedDollar,@Spell,pandocAmpersandEscape
syn match pandocHeaderAttr /{.*}/ contained containedin=pandocAtxHeader,pandocSetexHeader
syn match pandocHeaderID /#[-_:.[:lower:][:upper:]]*/ contained containedin=pandocHeaderAttr
" }}}2

" Line Blocks: {{{2
syn region pandocLineBlock start=/^|/ end=/\(^|\(.*\n|\@!\)\@=.*\)\@<=\n/ transparent
syn match pandocLineBlockDelimiter /^|/ contained containedin=pandocLineBlock
" }}}2



" Styling: {{{1
hi link pandocOperator Operator

" override this for consistency
hi pandocTitleBlock term=italic gui=italic
hi link pandocTitleBlockTitle Directory
hi link pandocAtxHeader Title
hi link pandocAtxStart Operator
hi link pandocSetexHeader Title
hi link pandocHeaderAttr Comment
hi link pandocHeaderID Identifier

hi link pandocLaTexSectionCmd texSection
hi link pandocLaTeXDelimiter texDelimiter

hi link pandocHTMLComment Comment
hi link pandocHTMLCommentStart Delimiter
hi link pandocHTMLCommentEnd Delimiter
hi link pandocBlockQuote Comment
hi link pandocBlockQuoteMark Comment
hi link pandocAmpersandEscape Special

hi link pandocDelimitedCodeBlockStart Delimiter
hi link pandocDelimitedCodeBlockEnd Delimiter
hi link pandocDelimitedCodeBlockLanguage Comment
hi link pandocBlockQuoteinDelimitedCodeBlock pandocBlockQuote
hi link pandocCodePre String

hi link pandocLineBlockDelimiter Delimiter

hi link pandocListItemBullet Operator
hi link pandocUListItemBullet Operator
hi link pandocListItemBulletId Identifier

hi link pandocReferenceLabel Label
hi link pandocReferenceURL Underlined
hi link pandocLinkTip Identifier
hi link pandocImageIcon Operator

hi link pandocReferenceDefinition Operator
hi link pandocReferenceDefinitionLabel Label
hi link pandocReferenceDefinitionAddress Underlined
hi link pandocReferenceDefinitionTip Identifier

hi link pandocAutomaticLink Underlined

hi link pandocDefinitionBlockTerm Identifier
hi link pandocDefinitionBlockMark Operator

hi link pandocSimpleTableDelims Delimiter
hi link pandocSimpleTableHeader pandocStrong
hi link pandocTableMultilineHeader pandocStrong
hi link pandocTableDelims Delimiter
hi link pandocGridTableDelims Delimiter
hi link pandocGridTableHeader Delimiter
hi link pandocPipeTableDelims Delimiter
hi link pandocPipeTableHeader Delimiter
hi link pandocTableHeaderWord pandocStrong

hi link pandocAbbreviationHead Type
hi link pandocAbbreviation Label
hi link pandocAbbreviationTail Type
hi link pandocAbbreviationSeparator Identifier
hi link pandocAbbreviationDefinition Comment

hi link pandocFootnoteID Label
hi link pandocFootnoteIDHead Type
hi link pandocFootnoteIDTail Type
hi link pandocFootnoteDef Comment
hi link pandocFootnoteDefHead Type
hi link pandocFootnoteDefTail Type
hi link pandocFootnoteBlock Comment
hi link pandocFootnoteBlockSeparator Operator

hi link pandocPCite Operator
hi link pandocICite Operator
hi link pandocCiteKey Label
hi link pandocCiteAnchor Operator
hi link pandocCiteLocator Operator

" Emphasis
hi pandocEmphasis gui=italic cterm=italic
hi pandocStrong gui=bold cterm=bold
hi pandocStrongEmphasis gui=bold,italic cterm=bold,italic
hi pandocStrongInEmphasis gui=bold,italic cterm=bold,italic
hi pandocEmphasisInStrong gui=bold,italic cterm=bold,italic
if !exists('s:hi_tail')
  let s:fg = '' " Vint can't figure ou these get set dynamically
  let s:bg = '' " so initialize them manually first
  for s:i in ['fg', 'bg']
    let s:tmp_val = synIDattr(synIDtrans(hlID('String')), s:i)
    let s:tmp_ui =  has('gui_running') || (has('termguicolors') && &termguicolors) ? 'gui' : 'cterm'
    if !empty(s:tmp_val) && s:tmp_val != -1
      exe 'let s:'.s:i . ' = "'.s:tmp_ui.s:i.'='.s:tmp_val.'"'
    else
      exe 'let s:'.s:i . ' = ""'
    endif
  endfor
  let s:hi_tail = ' '.s:fg.' '.s:bg
endif
exe 'hi pandocNoFormattedInEmphasis gui=italic cterm=italic'.s:hi_tail
exe 'hi pandocNoFormattedInStrong gui=bold cterm=bold'.s:hi_tail

hi link pandocNoFormatted String
hi link pandocNoFormattedAttrs Comment
hi link pandocSubscriptMark Operator
hi link pandocSuperscriptMark Operator
hi link pandocStrikeoutMark Operator

" Underline special
hi pandocSubscript gui=underline cterm=underline
hi pandocSuperscript gui=underline cterm=underline
hi pandocStrikeout gui=underline cterm=underline

hi link pandocNewLine Error
hi link pandocHRule Delimiter

let b:current_syntax = 'pandoc'

syntax sync clear
syntax sync minlines=1000
